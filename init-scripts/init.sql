create table if not exists doctors_table(
    npi varchar(10) primary key,
    doctor_first_name varchar(50) not null,
    doctor_last_name varchar(50) not null,
    extra_info varchar(30) null
);


insert into doctors_table(npi, doctor_first_name, doctor_last_name, extra_info)
values
    ('1255757134', 'Lyudmila', 'Magakyan',''),
    ('1255758134', 'Lyudmila', 'Magakyan', 'Wrong NPI'),
    ('1649258286', 'Dmitry', 'Khasak',''),
    ('1518674621', 'Jeffrey', 'Tuazon',''),
    ('Unknown', 'Unknown', 'Unknown','')
on conflict (npi) do nothing 
;

create table if not exists insurances_table(
    insurance_name varchar(50) primary key,
    phone_number varchar(10) null
);

create table if not exists medications_table(
    medication_name varchar(30) primary key,
    prerequisites varchar(1000) null,
    icd_code varchar(10) null,
    med_type varchar(50) null
);

create table if not exists pa_info_table(
    pa_id varchar(8) primary key,
    patient_first_name varchar(50) not null,
    patient_last_name varchar(50) not null,
    patient_dob date not null,
    drug_name varchar(50) not null references medications_table(medication_name),
    ema_id varchar(10) null,
    doctor_npi varchar(10) not null references doctors_table(npi),
    pa_status varchar(10) not null,
    submitted_at date not null,
    modified_at date not null default now(),
    insurance varchar(20) not null references insurances_table(insurance_name),
    submitted_by varchar(100) null,
    extra_info varchar(500) null
);


-- trigger function that “upserts” into medications_table
CREATE OR REPLACE FUNCTION ensure_medication_exists()
  RETURNS TRIGGER AS
$$
BEGIN
  IF NOT EXISTS (
    SELECT 1
      FROM medications_table
     WHERE medication_name = NEW.drug_name
  ) THEN
    INSERT INTO medications_table(medication_name)
    VALUES (NEW.drug_name);
  END IF;
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

-- attach to pa_info_table BEFORE each INSERT or UPDATE
CREATE TRIGGER trg_ensure_med
  BEFORE INSERT OR UPDATE ON pa_info_table
  FOR EACH ROW
  EXECUTE FUNCTION ensure_medication_exists();

-- trigger function to ensure insurance exists
CREATE OR REPLACE FUNCTION ensure_insurance_exists()
  RETURNS TRIGGER AS
$$
BEGIN
  -- If the insurance from the new PA row isn't in insurances_table, insert it
  IF NOT EXISTS (
    SELECT 1
      FROM insurances_table
     WHERE insurance_name = NEW.insurance
  ) THEN
    INSERT INTO insurances_table(insurance_name)
    VALUES (NEW.insurance);
  END IF;

  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

-- attach the trigger to pa_info_table
CREATE TRIGGER trg_ensure_insurance
  BEFORE INSERT OR UPDATE ON pa_info_table
  FOR EACH ROW
  EXECUTE FUNCTION ensure_insurance_exists();
