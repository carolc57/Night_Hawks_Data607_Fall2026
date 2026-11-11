select * from gsearch_jobs;

---Create new table sith subset of gsearch_jobs
	CREATE TABLE gsearch_jobs2 AS
	SELECT index, title, company_name, location, via, description, extensions, schedule_type, work_from_home,
     	salary_pay, salary_rate, salary_avg, salary_min, salary_max,salary_hourly, salary_yearly, salary_standardized,
	 description_tokens
	FROM gsearch_jobs;	

---Change data to Proper case (1st letter of each word capitalized) for title, company_name, location and description_tokens columns
   	UPDATE gsearch_jobs2 
  	 SET 
    	 title = INITCAP(title),
     	company_name = INITCAP(company_name),
    	 location = INITCAP(location),
     	description_tokens = INITCAP(description_tokens);

---Remove [] and ' ' from gsearch_jobs.description_tokens (keep commas)
	Update gsearch_jobs2
	set description_tokens = REGEXP_REPLACE(description_tokens,  '[^a-zA-Z,]', ' ', 'g');
	
---Create separate tables
   ---jobs table 
   CREATE TABLE jobs AS
  SELECT
      "index",
      title,
      company_name,
      location,
      via,
      description,
      schedule_type,
      work_from_home
  FROM gsearch_jobs2;
  
  ALTER TABLE jobs
  ADD PRIMARY KEY ("index");

---salary table
   CREATE TABLE salary (
    salary_id SERIAL PRIMARY KEY,
    index INTEGER REFERENCES jobs(index),
    salary_pay TEXT,
    salary_rate TEXT,
    salary_avg TEXT,
    salary_min TEXT,
    salary_max TEXT,
    salary_hourly TEXT,
    salary_yearly TEXT,
    salary_standardized TEXT
   );   

 ---create job_extensions table
   CREATE TABLE job_extensions (
    extension_id SERIAL PRIMARY KEY,
    index INTEGER REFERENCES jobs(index),
    extension_text TEXT
   );

 ---create job_skills table
   CREATE TABLE job_skills (
    skill_id SERIAL PRIMARY KEY,
    index INTEGER REFERENCES jobs(index),
    skill_name TEXT
   );
---Populate newly created tables

---populate salary table
INSERT INTO salary (
    index,
    salary_pay,
    salary_rate,
    salary_avg,
    salary_min,
    salary_max,
    salary_hourly,
    salary_yearly,
    salary_standardized
)
SELECT
    index,
    salary_pay,
    salary_rate,
    salary_avg,
    salary_min,
    salary_max,
    salary_hourly,
    salary_yearly,
    salary_standardized
FROM gsearch_jobs2;

---verify salary table
select * from salary;

---populate job_skills table
   INSERT INTO job_skills (
     index,
     skill_name
   )  
   SELECT 
     index, 
     description_tokens
   FROM gsearch_jobs2; 

---verify job_skills
select * from job_skills;  

---import/populate job_extensions table
   INSERT INTO job_extensions (
     index,
     extension_text
   )  
   SELECT 
     index, 
     extensions
   FROM gsearch_jobs2; 

---verify job_extension 
select * from job_extensions;

