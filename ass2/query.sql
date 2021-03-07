--PREAMBLE--
create view delay_day as
    select dayofmonth , sum(departuredelay + arrivaldelay) as delay_
    from flights join airports
            on flights.originairportid = airports.airportid
    where airports.city = 'Albuquerque'
    GROUP by dayofmonth;

create view days_ as
    select distinct *
    from
        (with recursive day_ (dayofmonth) as(
            select 1 as dayofmonth
            union
            select dayofmonth+1 as dayofmonth
            from day_
            where dayofmonth<=30 
        )
        select *
        from day_) as table1;

create view authorconnected as
    select distinct apl1.authorid as author1 , apl2.authorid as author2
    from authorpaperlist as apl1 join authorpaperlist as apl2
        on apl1.paperid = apl2.paperid
    where apl1.authorid <> apl2.authorid;

create view authorconnected2 as 
    select distinct *
    from
        (select author1,author2
        from authorconnected
        union
        select ac.author2 as author1, ac.author1 as author2
        from authorconnected as ac) as table1;


create view allpair as 
    select ad1.authorid as author1 , ad2.authorid as author2 , 
        ad1.authorname as author1name, ad2.authorname as author2name
    from authordetails as ad1 , authordetails as ad2
    where ad1.authorid <> ad2.authorid;

create view allcit as 
    select distinct *
    from
        (with recursive allcitations (paper1, paper2) as(
                select paperid1, paperid2
                from citationlist
            union
                select c.paper1 , cl.paperid2
                from allcitations as c join citationlist as cl 
                        on c.paper2 = cl.paperid1
            )
            select *
            from allcitations) as table_;

create view allcit2 as
    select distinct *
    from
        (select paper1,paper2
        from allcit
        union
        select ac.paper2 as paper1, ac.paper1 as paper2
        from allcit as ac) as table1;

create view totalcit as 
    select f.authorid, sum(distinct f.count) as total 
    from
        (select apl.authorid, ac2.paper1, count(distinct ac2.paper2) as count 
        from authorpaperlist as apl, allcit2 as ac2
        where apl.paperid = ac2.paper1
        GROUP by  apl.authorid, ac2.paper1)as f
    GROUP by f.authorid;

create view uniontotalcit as 
    (select *
    from totalcit
    union
    select ads.authorid , 0 as total
    from authordetails as ads
    where ads.authorid not in (select authorid from totalcit))
    order by authorid;

--1--
with recursive reachable (origin , dest, carrier) as(
        select originairportid, destairportid, carrier
        from flights
    union
        select r1.originairportid, r2.dest, r1.carrier
        from flights as r1, reachable as r2
        where r1.destairportid = r2.origin and r2.carrier = r1.carrier
    )
select distinct airports.city as name
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
select distinct airports.city as name
from reachable join airports on dest= airportid
where reachable.origin = 10140
order by airports.city;

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
    where r.dest <> all(r.path_)
    GROUP by airports.city
    HAVING count(r.path_) = 1
    order by airports.city;

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
    select length_ as length
    from longest
    where origin = dest and origin = 10140
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
    select length_ as length
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
        where air1.city = 'Albuquerque'
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
    where dest_city = 'Chicago' and dest_city <> all(path_);

--7--
with recursive numpaths (origin_city , path_, dest_city) as(
        select air1.city , ARRAY[air1.city] as path_ , air2.city
        from flights join airports as air1 on
                flights.originairportid = air1.airportid
                join airports as air2 on 
                flights.destairportid = air2.airportid
        where air1.city = 'Albuquerque'
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
    where dest_city = 'Chicago' and dest_city <> all(path_) and 'Washington' = some(path_);

--8--
(   
    (select air1.city as name1, air2.city as name2
    from airports as air1 , airports as air2
    where air1.airportid <> air2.airportid)
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
    (select dayofmonth ,delay_
    from delay_day
    union
    select dayofmonth, 0 as delay_
    from days_
    where dayofmonth not in (select dayofmonth from delay_day)
    ) as table1
order by delay_, dayofmonth;

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
    select distinct origin_city as name1, dest_city as name2
    from incdelay
    order by name1, name2;

--12--
with recursive AtoB (path_ , depth_ , author) as( 
        select ARRAY[author1] as path_ , 1 as depth_ , author2
        from authorconnected as ac
        where author1 = 1235
    union
        select p.path_ || ac.author1 , p.depth_ + 1 as depth_, ac.author2
        from authorconnected as ac join AtoB as p
            on p.author = ac.author1
        where p.author <> all(p.path_)
    )
    (
        (select authorid , count as length
        from
            (select author as authorid , depth_ as count , 
                row_number() over(partition by author order by depth_) as rnk
            from AtoB
            where author != 1235 and author <> all(path_)
            )as table1
        where rnk = 1
        )
    union
        (select ap.author2 as authorid, -1 as length
        from allpair as ap
        where ap.author1 = 1235 and ap.author2 not in   (select author
                                                        from AtoB
                                                        )
        )
    )
    order by length DESC , authorid;

--13-- 
with recursive 
    AtoB (author1, path_ , depth_ , gender, author2) as( 
        select author1 , ARRAY[author1] as path_ , 1 as depth_ , '' as gender , author2
        from authorconnected as ac
        where author1 = 1558
    union
        select p.author1, p.path_ || ac.author1 , p.depth_ + 1 as depth_, ad1.gender , ac.author2
        from authorconnected as ac 
            join AtoB as p on p.author2 = ac.author1
            join authordetails as ad1 on ad1.authorid = p.author2
            join authordetails as ad2 on ad2.authorid = ac.author2
        where ((p.depth_ = 1 and ad1.age > 35 ) or ( p.depth_ >=2 and ad1.age > 35 and ad1.gender != p.gender )) and ac.author1 <> all(p.path_)
    ),
    componentsA (author1, author2) as(
        select author1, author2
        from authorconnected as ac
        where author1 = 1558
    union
        select ca.author1 , ac.author2
        from authorconnected as ac
            join componentsA as ca on ca.author2 = ac.author1
    )
    select
        case
            when 2826 in (  select author2
                            from componentsA) 
                then (select
                        case
                        when 2826 in (select author2 from AtoB) then (select count(distinct path_) as count
                                                                    from AtoB
                                                                    where author2 = 2826 and author2<>all(path_)
                                                                    GROUP by author2 )
                        else 0
                        end as count)
            else -1
        end as count; 

--14--
with recursive 
    AtoB (author1, path_ , depth_ , cited, author2) as( 
        select author1 , ARRAY[author1] as path_ , 1 as depth_ , 'true' as cited , author2
        from authorconnected as ac
        where author1 = 704
    union
        select p.author1, p.path_ || ac.author1 , p.depth_ + 1 as depth_ ,
            (case
                when apl.paperid = some(  select distinct paper2                            
                                        from allcit2
                                        where paper1 = 126) then 'true'                
                when depth_ = 1 then 'false'
                when cited = 'true' then 'true'
                else 'false'
            end) as cited, ac.author2
        from authorconnected as ac 
            join AtoB as p on p.author2 = ac.author1
            join authorpaperlist as apl on apl.authorid = p.author2
        where ac.author1 <>all(p.path_)
    )
    select
    case
        when 102 in (  select author2
                        from AtoB) 
            then (  select count(distinct path_) as count
                    from AtoB
                    where author2 = 102 and cited = 'true' and author2<> all(path_)
                    GROUP by author2
                )
        else -1
    end as count;

--15--
with recursive 
    AtoB (author1, path_ , depth_ , totalcitation, author2) as( 
        select author1 , ARRAY[author1] as path_ , 1 as depth_ , utct.total as totalcitation, author2
        from authorconnected as ac join uniontotalcit as utct on utct.authorid = ac.author1
        where author1 = 1745
    union
        select p.author1, p.path_ || ac.author1 , p.depth_ + 1 as depth_ ,utct.total as totalcitation, ac.author2
        from authorconnected as ac 
            join AtoB as p on p.author2 = ac.author1
            join uniontotalcit as utct on utct.authorid = p.author2
        where ((depth_ = 1) or (depth_>=2 and utct.total>p.totalcitation)) and ac.author1 <> all(p.path_)
    ),
    componentsA (author1, author2) as(
        select author1, author2
        from authorconnected as ac
        where author1 = 1745
    union
        select ca.author1 , ac.author2
        from authorconnected as ac
            join componentsA as ca on ca.author2 = ac.author1
    )
    select
    case
        when 456 in (  select author2
                        from componentsA) 
            then (select
                    case
                    when 456 in (select author2 from AtoB) then (select count(distinct path_) as count
                                                                from AtoB
                                                                where author2 = 456 and author2 <> all(path_)
                                                                GROUP by author2 )
                    else 0
                    end as count)
        else -1
    end as count; 

--16--

--17--

--18--
with recursive 
    AtoB (author1, path_ , depth_ , author2) as( 
        select author1 , ARRAY[author1] as path_, 1 as depth_ , author2
        from authorconnected as ac
        where author1 = 3552
    union
        select p.author1, (p.path_ || ac.author1) as path_, p.depth_ + 1 as depth_, ac.author2
        from authorconnected as ac 
            join AtoB as p on p.author2 = ac.author1
        where ac.author1 <> all(p.path_)
    )
    select
    case
        when 321 in (  select distinct author2
                        from AtoB) 
            then (  select count(distinct path_) as count
                    from AtoB
                    where (1436 = some(path_) 
                        or 562 = some(path_)
                        or 921 = some(path_))
                        and author2 = 321 and author2<>all(path_)
                    GROUP by author2
                 )
        else -1
    end as count;

--19--
with recursive 
    AtoB (author1, path_ , depth_ , city_, paper_, author2) as( 
        select author1 , ARRAY[author1] as path_ , 1 as depth_ ,
             array[''] as city_ ,array[-1] as paper_, author2
        from authorconnected as ac
        where author1 = 3552
    union
        select p.author1, p.path_ || ac.author1 , p.depth_ + 1 as depth_,
            p.city_ || ad1.city , p.paper_ || apd.paperid , ac.author2
        from authorconnected as ac 
            join AtoB as p on p.author2 = ac.author1
            join authordetails as ad1 on ad1.authorid = p.author2
            join authorpaperlist as apd on apd.authorid = p.author2
            join citationlist as cl on cl.paperid1 = apd.paperid
        where ((p.depth_ = 1 ) or ( p.depth_ >=2 and ad1.city <> all(p.city_) and cl.paperid2 <> all(p.paper_))) 
            and ac.author1 <> all(p.path_)
    ),
    componentsA (author1, author2) as(
        select author1, author2
        from authorconnected as ac
        where author1 = 3552
    union
        select ca.author1 , ac.author2
        from authorconnected as ac
            join componentsA as ca on ca.author2 = ac.author1
    )
    select
    case
        when 321 in (  select author2
                        from componentsA) 
            then (select
                    case
                    when 321 in (select author2 from AtoB) then (select count(distinct path_) as count
                                                                from AtoB
                                                                where author2 = 321 and author2<>all(path_)
                                                                GROUP by author2 )
                    else 0
                    end as count)
        else -1
    end as count;

--20--
with recursive 
    AtoB (author1, path_ , depth_ , city_, paper_, author2) as( 
        select author1 , ARRAY[author1] as path_ , 1 as depth_ ,
             array[''] as city_ ,array[-1] as paper_, author2
        from authorconnected as ac
        where author1 = 3552
    union
        select p.author1, p.path_ || ac.author1 , p.depth_ + 1 as depth_,
            p.city_ || ad1.city , p.paper_ || apd.paperid , ac.author2
        from authorconnected as ac 
            join AtoB as p on p.author2 = ac.author1
            join authordetails as ad1 on ad1.authorid = p.author2
            join authorpaperlist as apd on apd.authorid = p.author2
            join allcit as act on act.paper1 = apd.paperid
        where ((p.depth_ = 1 ) or ( p.depth_ >=2 and ad1.city <> all(p.city_) and act.paper2 <> all(p.paper_))) 
            and ac.author1 <> all(p.path_)
    ),
    componentsA (author1, author2) as(
        select author1, author2
        from authorconnected as ac
        where author1 = 3552
    union
        select ca.author1 , ac.author2
        from authorconnected as ac
            join componentsA as ca on ca.author2 = ac.author1
    )
    select
    case
        when 321 in (  select author2
                        from componentsA) 
            then (select
                    case
                    when 321 in (select author2 from AtoB) then (select count(distinct path_) as count
                                                                from AtoB
                                                                where author2 = 321 and author2<>all(path_)
                                                                GROUP by author2 )
                    else 0
                    end as count)
        else -1
    end as count;

--21--

--22--

--CLEANUP--
drop view delay_day;
drop view days_;
drop view authorconnected2;
drop view authorconnected;
drop view allpair;
drop view uniontotalcit;
drop view totalcit;
drop view allcit2;
drop view allcit;