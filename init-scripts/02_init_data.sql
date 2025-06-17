insert into doctors_table(npi, doctor_first_name, doctor_last_name, extra_info)
values
    ('1255757134', 'Lyudmila', 'Magakyan',''),
    ('1255758134', 'Lyudmila', 'Magakyan', 'Wrong NPI'),
    ('1649258286', 'Dmitry', 'Khasak',''),
    ('1518674621', 'Jeffrey', 'Tuazon',''),
    ('Unknown', 'Unknown', 'Unknown','')
on conflict (npi) do nothing 
;