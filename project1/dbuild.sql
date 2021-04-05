DROP TABLE IF EXISTS acquisitions, degrees, funding_rounds, funds, investments, ipos, milestones, objects, offices, people, relationships;

create table acquisitions(
    id bigint NOT NULL,
    acquisition_id bigint NOT NULL,
    acquiring_object_id text NOT NULL,
    acquired_object_id text,
    term_code text,
    price_amount decimal(18,1),
    price_currency_code text,
    acquired_at date,
    source_url text,
    source_description text,
    created_at timestamp,
    updated_at timestamp,
    PRIMARY KEY (id)
);

create table degrees(
    id bigint NOT NULL,
    object_id text NOT NULL,
    degree_type text,
    subject text,
    institution text,
    graduated_at date,
    created_at timestamp,
    updated_at timestamp,
    PRIMARY KEY (id)
);

create table funding_rounds(
    id bigint NOT NULL,
    funding_round_id bigint NOT NULL,
    object_id text NOT NULL,
    funded_at date,
    funding_round_type text,
    funding_round_code text,
    raised_amount_usd decimal(18,1),
    raised_amount decimal(18,1),
    raised_currency_code text,
    pre_money_valuation_usd decimal(18,1),
    pre_money_valuation decimal(18,1),
    pre_money_currency_code text,
    post_money_valuation_usd decimal(18,1),
    post_money_valuation decimal(18,1),
    post_money_currency_code text,
    participants int,
    is_first_round bit,
    is_last_round bit,
    source_url text,
    source_description text,
    created_by text,
    created_at timestamp,
    updated_at timestamp,
    PRIMARY KEY (id)
);

create table funds(
    id bigint NOT NULL,
    fund_id bigint NOT NULL,
    object_id text NOT NULL,
    name text,
    funded_at date,
    raised_amount decimal(18,1),
    raised_currency_code text,
    source_url text,
    source_description text,
    created_at timestamp,
    updated_at timestamp,
    PRIMARY KEY (id)
);

create table investments(
    id bigint NOT NULL,
    funding_round_id bigint NOT NULL,
    funded_object_id text NOT NULL,
    investor_object_id text NOT NULL,
    created_at timestamp,
    updated_at timestamp,
    PRIMARY KEY (id)
);

create table ipos(
    id bigint NOT NULL,
    ipo_id bigint NOT NULL,
    object_id text,
    valuation_amount decimal(18,1),
    valuation_currecny_code text,
    raised_amount decimal(18,1),
    raised_currency_code text,
    public_at date,
    stock_symbol text NOT NULL,
    source_url text,
    source_description text,
    created_at timestamp,
    updated_at timestamp,
    PRIMARY KEY (id)
);

create table milestones(
    id bigint NOT NULL,
    object_id text NOT NULL,
    milestone_at date,
    milestone_code text,
    description text,
    source_url text,
    source_description text,
    created_at timestamp,
    updated_at timestamp,
    PRIMARY KEY (id)
);

create table objects(
    id text NOT NULL,
    entity_type text,
    entity_id bigint NOT NULL,
    parent_id text,
    name text,
    normalized_name text,
    permalink text NOT NULL,
    category_code text,
    status text,
    founded_at date,
    closed_at date,
    domain text,
    homepage_url text,
    twitter_username text,
    logo_url text,
    logo_width int,
    logo_height int,
    short_description text,
    description text,
    overview text,
    tag_list text,
    country_code text,
    state_code text,
    city text,
    region text,
    first_investment_at date,
    last_investment_at date,
    investment_rounds smallint,
    invested_companies smallint,
    first_funding_at date,
    last_funding_at date,
    funding_rounds smallint,
    funding_total_usd decimal(18,1),
    first_milestion_at date,
    last_milestone_at date,
    milestones smallint,
    relationships smallint,
    created_by text,
    created_at timestamp,
    updated_at timestamp,
    PRIMARY KEY (id)
);

create table offices(
    id bigint NOT NULL,
    object_id text NOT NULL,
    office_id bigint NOT NULL,
    description text,
    region text,
    address1 text,
    address2 text,
    city text,
    zip_code text,
    state_code text,
    country_code text,
    latitude text,
    longitude text,
    created_at timestamp,
    updated_at timestamp,
    PRIMARY KEY (id)
);

create table people(
    id bigint NOT NULL,
    object_id text NOT NULL,
    first_name text,
    last_name text,
    birthplace text,
    affliation_name text,
    PRIMARY KEY (id)
);

create table relationships(
    id bigint NOT NULL,
    relationship_id bigint NOT NULL,
    person_object_id text NOT NULL,
    relationship_object_id text NOT NULL,
    start_at date,
    end_at date,
    is_past bigint,
    sequence bigint,
    title text,
    created_at timestamp,
    updated_at timestamp,
    PRIMARY KEY (id)
);
