--1--
with recursive reachable (origin , dest, carrier) as(
        select originairportid, destairportid, carrier
        from flights
    union
        select r1.originairportid, r2.dest, r1.carrier
        from flights as r1, reachable as r2
        where r1.destairportid = r2.origin and r2.carrier = r1.carrier
    )
select (airports.city) as name
from reachable join airports on dest= airportid
where reachable.origin = 10140
order by airports.city;

--2--
with recursive reachable (origin , dest, day) as(
        select originairportid, destairportid, dayofweek
        from flights
    union
        select r1.originairportid, r2.dest, r2.day
        from flights as r1, reachable as r2
        where r1.destairportid = r2.origin
            and r1.dayofweek = r2.day
    )
select airports.city as name
from reachable join airports on dest= airportid
where reachable.origin = 10140
order by name;

--3--
with recursive reachone (origin , path_, dest) as(
        select originairportid, ARRAY[originairportid] as path_, destairportid
        from flights
        where flights.originairportid = 10140
    union
        select r1.origin, r1.path_ || flights.originairportid as path_, flights.destairportid
        from reachone as r1 JOIN flights 
            on r1.dest = flights.originairportid
        where flights.originairportid <> all(r1.path_)
    )
    select airports.city as name
    from reachone as r join airports
        on r.dest = airports.airportid
    GROUP by airports.city
    HAVING count(r.path_) = 1
    order by name;

--4--
with recursive longest (origin , path_, length_ , dest) as(
        select originairportid, ARRAY[originairportid] as path_, 1 as length_ , destairportid
        from flights
    union
        select r1.origin, r1.path_ || flights.originairportid as path_, r1.length_ + 1 as length_ ,flights.destairportid
        from longest as r1 JOIN flights 
            on r1.dest = flights.originairportid
        where flights.originairportid <> all(r1.path_)
    )
    select length_
    from longest
    where 10140 = some(longest.path_) and dest = origin
    order by length_ desc
    limit 1;    

--5--
with recursive longest (origin , path_, length_ , dest) as(
        select originairportid, ARRAY[originairportid] as path_, 1 as length_ , destairportid
        from flights
    union
        select r1.origin, r1.path_ || flights.originairportid as path_, r1.length_ + 1 as length_ ,flights.destairportid
        from longest as r1 JOIN flights 
            on r1.dest = flights.originairportid
        where flights.originairportid <> all(r1.path_)
    )
    select length_
    from longest
    where dest = origin
    order by length_ desc
    limit 1;

--6--
with recursive numpaths (origin_city , path_, dest_city) as(
        select air1.city , ARRAY[air1.city] as path_ , air2.city
        from flights join airports as air1 on
                flights.originairportid = air1.airportid
                join airports as air2 on 
                flights.destairportid = air2.airportid
        where air1.name = 'Albuquerque'
                and air1.state <> air2.state
    union
        select np.origin_city, np.path_ || air1.city as path_, air2.city
        from flights join airports as air1
                on flights.originairportid = air1.airportid
                    join airports as air2
                on flights.destairportid = air2.airportid 
                    join numpaths as np 
                on np.dest_city = air1.city
        where air1.state <> air2.state
                and air1.city <> all(np.path_)
    )
    select count(path_) as count
    from numpaths
    where dest_city = 'Chicago';

--7--
with recursive numpaths (origin_city , path_, dest_city) as(
        select air1.city , ARRAY[air1.city] as path_ , air2.city
        from flights join airports as air1 on
                flights.originairportid = air1.airportid
                join airports as air2 on 
                flights.destairportid = air2.airportid
        where air1.name = 'Albuquerque'
    union
        select np.origin_city, np.path_ || air1.city as path_, air2.city
        from flights join airports as air1
                on flights.originairportid = air1.airportid
                    join airports as air2
                on flights.destairportid = air2.airportid 
                    join numpaths as np 
                on np.dest_city = air1.city
        where air1.city <> all(np.path_)
    )
    select count(path_) as count
    from numpaths
    where dest_city = 'Chicago' and 'Washington' = some(path_);

--8--
(   
    (select city1.city as name1, city2.city as name2
    from
        (select city
        from flights join airports 
                on originairportid = airportid
        union
        select city
        from flights join airports 
                on originairportid = airportid
        )as city1,
        (select city
        from flights join airports 
                on originairportid = airportid
        union
        select city
        from flights join airports 
                on originairportid = airportid
        )as city2
    where city1.city <> city2.city)

    EXCEPT

    (with recursive apath (origin_city, dest_city) as(
        select air1.city , air2.city
        from flights join airports as air1 
                on flights.originairportid = air1.airportid
                    join airports as air2 
                on flights.destairportid = air2.airportid
        union
        select ap.origin_city, air2.city
        from flights join airports as air1
                on flights.originairportid = air1.airportid
                    join airports as air2
                on flights.destairportid = air2.airportid 
                    join apath as ap 
                on ap.dest_city = air1.city        
        )
        select origin_city as name1, dest_city as name2
        from apath
    )
)
order by name1, name2;

--9--
select dayofmonth as day
from
    (select dayofmonth , sum(departuredelay + arrivaldelay) as delay_
    from flights join airports
            on flights.originairportid = airports.airportid
    where airports.city = 'Albuquerque'
    GROUP by dayofmonth) as table1
order by delay_ , day;

--10--
select a1.city as name
from flights join airports as a1 on a1.airportid = flights.originairportid
             join airports as a2 on a2.airportid = flights.destairportid
where a1.state = 'New York' and a2.state = 'New York'
GROUP BY a1.city
HAVING count(distinct a2.city) =    ((select count(distinct city)
                                    from airports
                                    where state = 'New York'
                                    ) - 1)
order by name;

--11--
with recursive incdelay (origin_city, dest_city, delay_) as(
        select a1.city, a2.city, (flights.departuredelay + flights.arrivaldelay) as delay_
        from flights join airports as a1 on a1.airportid = flights.originairportid
                    join airports as a2 on a2.airportid = flights.destairportid
    union
        select incdelay.origin_city, a2.city, (flights.departuredelay + flights.arrivaldelay) as delay_
        from flights join airports as a1 on a1.airportid = flights.originairportid
                    join airports as a2 on a2.airportid = flights.destairportid
                    join incdelay on incdelay.dest_city = a1.city
        where (flights.departuredelay + flights.arrivaldelay) >= incdelay.delay_
    )
    select origin_city as name1, dest_city as name2
    from incdelay
    where origin_city <> dest_city
    order by origin_city, dest_city;
