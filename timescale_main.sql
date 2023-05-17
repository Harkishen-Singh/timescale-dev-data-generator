-- common table
create table metric (
    time timestamptz not null,
    series_id bigint not null,
    value double precision not null
);

create unique index metric_idx on metric using btree (time, series_id);

SELECT create_hypertable('metric', 'time', chunk_time_interval => INTERVAL '1 week');

insert into metric (time, series_id, value)
    select
        t as time,
        floor(random() * 100) as series_id,
        random() as value
    from
        generate_series('2020-01-01'::date, '2020-12-31'::date, '1 hour') AS t;

create view metric_aggregates as
    select
        series_id, avg(value), min(value), max(value), sum(value), count(value) from metric group by series_id order by series_id;

create materialized view metric_aggregates_mat_view as
    select
        series_id, avg(value), min(value), max(value), sum(value), count(value) from metric group by series_id order by series_id limit 10 with data;

-- table specific to a user
create user shyam with password 'hsinghbb' login;

create table metric_user_specific (
    time timestamptz not null,
    series_id bigint not null,
    value double precision not null
);

create unique index metric_user_specific_idx on metric_user_specific using btree (time, series_id);

SELECT create_hypertable('metric_user_specific', 'time', chunk_time_interval => INTERVAL '1 week');

grant select on metric_user_specific to shyam;

insert into metric_user_specific (time, series_id, value)
    select
        t as time,
        floor(random() * 100) as series_id,
        random() as value
    from
        generate_series('2020-01-01'::date, '2020-12-31'::date, '1 hour') AS t;

create view metric_user_specific_aggregates as
    select
        series_id, avg(value), min(value), max(value), sum(value), count(value) from metric group by series_id order by series_id;

grant select on metric_user_specific_aggregates to shyam;

create materialized view metric_user_specific_aggregates_mat_view as
    select
        series_id, avg(value), min(value), max(value), sum(value), count(value) from metric group by series_id order by series_id limit 10 with data;


