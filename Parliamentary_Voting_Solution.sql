
CREATE SEQUENCE  PARLIAMENTSQ  MINVALUE 1 INCREMENT BY 1 START WITH 1;

/* ******************* TABLE CREATION **********************/
create table region (
    region_code varchar2(50) primary key,
    region_name varchar2(250) unique
);

create table constituency (
    constituency_code varchar2(50) primary key,
    constituency_name varchar2(250) unique,
    region_code varchar2(250) references region
);

create table mp (
    mp_code varchar2(50) primary key,
    constituency_code varchar2(250) references constituency,
    mp_lastname varchar2(250),
    mp_othernames varchar2(250),
    mp_dob date
);

create table political_party (
    party_code varchar2(50) primary key,
    party_name varchar2(250) unique
);

create table parliamentary_session (
    session_code varchar2(50) primary key,
    session_name varchar2(250) unique,
    start_date date,
    end_date date
);

create table mp4_session (
    mp_code varchar2(50),
    session_code varchar2(50),
    party_code varchar2(50),
    date_joined date,
    
    constraint pk_mp4_sess primary key(mp_code,session_code, party_code),
    constraint fk_mp4_sess_mp foreign key(mp_code) references mp(mp_code),
    constraint fk_mp4_sess_parl foreign key(session_code) references parliamentary_session(session_code),
    constraint fk_mp4_sess_party foreign key(party_code) references political_party(party_code)
);

create table sponsor (
    sponsor_code varchar2(50) primary key,
    sponsor_name varchar2(250) unique
);

create table bills (
    bill_code varchar2(50) primary key,
    bill_name varchar2(250) unique,
    sponsor_code varchar2(50) references sponsor,
    bill_date date,
    bill_status varchar2(10) default 'pending' check (lower(bill_status) in ('pending','yes','no'))
);

create table bill_vote (
    mp_code varchar2(50),
    session_code varchar2(50) ,
    party_code varchar2(50),
    bill_code varchar2(50) references bills,
    vote varchar2(10) check (lower(vote) in ('yes','no','abstain','absent')),
    vote_date date,
    
    constraint pk_bill_vote primary key(mp_code, session_code, party_code, bill_code),
    constraint fk_bill_vote foreign key(mp_code, session_code, party_code) references mp4_session(mp_code, session_code, party_code)
);

/************************** PROCEDURES **************************/

create or replace PROCEDURE ADD_REGION(
    p_region_name in region.region_name%type,
    p_result out number
) AS 

v_region_code region.region_code%type;

repeated_region_name exception;
pragma exception_init(repeated_region_name,-00001);

BEGIN
    v_region_code := 'GH-REG-00' || parliamentsq.nextval;
    
    insert into region values (v_region_code, upper(p_region_name));
    
    if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('Region created successfully');
    else
        p_result := 0;
        dbms_output.put_line('Region not created');
    end if;

    exception
    when repeated_region_name then
        dbms_output.put_line('Region name already exists');
    when others then
        dbms_output.put_line('Sorry could not create your record');
    
END ADD_REGION;

CREATE OR REPLACE PROCEDURE UPDATE_REGION (
    p_region_code in region.region_code%type,
    p_region_name in region.region_name%type,
    p_result out number
)AS 

repeated_region_name exception;
pragma exception_init(repeated_region_name,-00001);

BEGIN
    
    update region set region_name = upper(p_region_name) 
    where upper(region_code)= upper(p_region_code);
    
    if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('Region updated successfully');
    else
        p_result := 0;
        dbms_output.put_line('Region not updated');
        
        if sql%notfound then  
            dbms_output.put_line('Invalid Region Code');
        end if;     
    end if;           
    
    exception
    when repeated_region_name then
        dbms_output.put_line('Region name already exists');
    when others then
        dbms_output.put_line('Sorry could not update your record');
        
    
END UPDATE_REGION;

CREATE OR REPLACE PROCEDURE DELETE_REGION (
    p_region_code in region.region_code%type,
    p_result out number
)AS 

BEGIN
    
    delete from region where upper(region_code) = upper(p_region_code);
    
    if sql%notfound then
        dbms_output.put_line('Delete failed. Invalid region code.');
    end if;
    
    if sql%rowcount = 1 then
        dbms_output.put_line('Delete successful');
    end if;
    
END DELETE_REGION;

CREATE OR REPLACE PROCEDURE ADD_CONSTITUENCY (
    p_const_name in constituency.constituency_name%type,
    p_region_code in constituency.region_code%type,
    p_result out number
) AS 

v_const_code constituency.constituency_code%type;

repeated_const_name exception;
pragma exception_init(repeated_const_name,-00001);

invalid_region_code exception;
pragma exception_init(invalid_region_code,-02291);

BEGIN
    v_const_code := 'GH-CONST-00' || parliamentsq.nextval;
    
    insert into constituency values (v_const_code, upper(p_const_name),upper(p_region_code));
    
    if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('Constituency created successfully');
    else
        p_result := 0;
        dbms_output.put_line('Constituency not created');
    end if;

    exception
    when repeated_const_name then
        dbms_output.put_line('Constituency name already exists');
    when invalid_region_code then
        dbms_output.put_line('Invalid region code. Code does not exist');
    when others then
        dbms_output.put_line('Sorry could not create your record');
    
END ADD_CONSTITUENCY;

CREATE OR REPLACE PROCEDURE UPDATE_CONSTITUENCY (
    p_const_code in constituency.constituency_code%type,
    p_const_name in constituency.constituency_name%type,
    p_region_code in constituency.region_code%type,
    p_result out number
)AS 

repeated_const_name exception;
pragma exception_init(repeated_const_name,-00001);

invalid_region_code exception;
pragma exception_init(invalid_region_code,-02291);

BEGIN
    
    update constituency set constituency_name = upper(p_const_name), region_code = upper(p_region_code)
    where upper(constituency_code) = upper(p_const_code);
    
    if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('Constituency updated successfully');
    else
        p_result := 0;
        dbms_output.put_line('Constituency not updated');
        
        if sql%notfound then  
            dbms_output.put_line('Invalid Constituency Code');
        end if;     
    end if;           
    
    exception
    when repeated_const_name then
        dbms_output.put_line('Update failed. Constituency name already exists');
    when invalid_region_code then
        dbms_output.put_line('Update failed. Region code does not exist');
    when others then
        dbms_output.put_line('Sorry could not update your record');
        
END UPDATE_CONSTITUENCY;

CREATE OR REPLACE PROCEDURE DELETE_CONSTITUENCY (
    p_const_code in constituency.constituency_code%type,
    p_result out number
) AS 
BEGIN
    
    delete from constituency where upper(constituency_code) = upper(p_const_code);
    
    if sql%notfound then
        dbms_output.put_line('Delete failed. Invalid constituency code.');
    end if;
    
    if sql%rowcount = 1 then
        dbms_output.put_line('Delete successful');
    end if;
    
END DELETE_CONSTITUENCY;

CREATE OR REPLACE PROCEDURE ADD_MP (
    p_const_code in MP.CONSTITUENCY_CODE%type,
    p_mp_lastname in MP.MP_LASTNAME%type,
    p_mp_othernames in MP.MP_OTHERNAMES%type,
    p_mp_dob in MP.MP_DOB%type,
    p_result out number    
) AS 

invalid_const_code exception;
pragma exception_init(invalid_const_code,-02291);

v_mpcode MP.MP_CODE%type;

BEGIN
    v_mpcode := 'GHMP-' || to_char(sysdate,'yyyy') || '-00' || PARLIAMENTSQ.NEXTVAL;
    
    insert into mp values (v_mpcode, upper(p_const_code), upper(p_mp_lastname), upper(p_mp_othernames), p_mp_dob);
    
    if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('MP infomation created successfully');
    else
        p_result := 0;
        dbms_output.put_line('MP not created');
    end if;

    exception
    when invalid_const_code then
        dbms_output.put_line('Invalid constituency code. Code does not exist');
    when others then
        dbms_output.put_line('Sorry could not create your record');
    
END ADD_MP;

CREATE OR REPLACE PROCEDURE UPDATE_MP (
    p_mpcode in MP.MP_CODE%type,
    p_const_code in MP.CONSTITUENCY_CODE%type,
    p_mp_lastname in MP.MP_LASTNAME%type,
    p_mp_othernames in MP.MP_OTHERNAMES%type,
    p_mp_dob in MP.MP_DOB%type,
    p_result out number  
    
) AS 

invalid_const_code exception;
pragma exception_init(invalid_const_code,-02291);

BEGIN
    update mp 
    set constituency_code = upper(p_const_code), mp_lastname = upper(p_mp_lastname), 
        mp_othernames = upper(p_mp_othernames), mp_dob = p_mp_dob
    where upper(mp_code) = upper(p_mpcode);
    
    if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('MP updated successfully');
    else
        p_result := 0;
        dbms_output.put_line('MP not updated');
        
        if sql%notfound then  
            dbms_output.put_line('Invalid MP Code');
        end if;     
    end if;           
    
    exception
    when invalid_const_code then
        dbms_output.put_line('Update failed. Constituency code does not exist');
    when others then
        dbms_output.put_line('Sorry could not update your record');
    
        
END UPDATE_MP;

CREATE OR REPLACE PROCEDURE DELETE_MP (
    p_mp_code in MP.MP_CODE%type,
    p_result out number
)AS 
BEGIN
    delete from mp where upper(mp_code) = upper(p_mp_code);
    
    if sql%notfound then
        dbms_output.put_line('Delete failed. Invalid MP code.');
    end if;
    
    if sql%rowcount = 1 then
        dbms_output.put_line('Delete successful');
    end if;
END DELETE_MP;

CREATE OR REPLACE PROCEDURE ADD_POLITICAL_PARTY (
    p_party_name in POLITICAL_PARTY.PARTY_NAME%type,
    p_result out number
)AS 

v_party_code POLITICAL_PARTY.PARTY_CODE%type;

repeated_party_name exception;
pragma exception_init(repeated_party_name,-00001);

BEGIN
    v_party_code := 'GHPP-00' || parliamentsq.nextval;
    
    insert into political_party values (v_party_code, upper(p_party_name));
    
    if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('Party created successfully');
    else
        p_result := 0;
        dbms_output.put_line('Party not created');
    end if;

    exception
    when repeated_party_name then
        dbms_output.put_line('Political Party already exists');
    when others then
        dbms_output.put_line('Sorry could not create your record');
        
END ADD_POLITICAL_PARTY;

CREATE OR REPLACE PROCEDURE UPDATE_POLITICAL_PARTY (
    p_party_code in POLITICAL_PARTY.PARTY_CODE%type,
    p_party_name in POLITICAL_PARTY.PARTY_NAME%type,
    p_result out number
) AS

repeated_party_name exception;
pragma exception_init(repeated_party_name,-00001);

BEGIN
    
    update political_party set party_name = upper(p_party_name) 
    where upper(party_code) = upper(p_party_code);
    
    if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('Political party updated successfully');
    else
        p_result := 0;
        dbms_output.put_line('Political party not updated');
        
        if sql%notfound then  
            dbms_output.put_line('Invalid Political party Code. Code does not exist');
        end if;     
    end if;           
    
    exception
    when repeated_party_name then
        dbms_output.put_line('Political party name already exists');
    when others then
        dbms_output.put_line('Sorry could not update your record');
        
END UPDATE_POLITICAL_PARTY;

CREATE OR REPLACE PROCEDURE DELETE_POLITICAL_PARTY 
(
    p_party_code in POLITICAL_PARTY.PARTY_CODE%type,
    p_result out number
)AS 

BEGIN
    delete from political_party where upper(party_code) = upper(p_party_code);
    
    if sql%notfound then
        dbms_output.put_line('Delete failed. Party code does not exist.');
    end if;
    
    if sql%rowcount = 1 then
        dbms_output.put_line('Delete successful');
    end if;
    
END DELETE_POLITICAL_PARTY;

CREATE OR REPLACE PROCEDURE ADD_SPONSOR (
    p_sponsor in SPONSOR.SPONSOR_NAME%type,
    p_result out number
)AS 

v_sponsor_code SPONSOR.SPONSOR_CODE%type;

repeated_sponsor exception;
pragma exception_init(repeated_sponsor,-00001);

BEGIN
    v_sponsor_code := 'BSPR-00' || parliamentsq.nextval;
    
    insert into sponsor values (v_sponsor_code, upper(p_sponsor));
    
    if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('Sponsor created successfully');
    else
        p_result := 0;
        dbms_output.put_line('Sponsor not created');
    end if;

    exception
    when repeated_sponsor then
        dbms_output.put_line('Sponsor name already exists');
    when others then
        dbms_output.put_line('Sorry could not create your record');
        
END ADD_SPONSOR;

CREATE OR REPLACE PROCEDURE UPDATE_SPONSOR (
    p_sponsor_code in SPONSOR.SPONSOR_CODE%type,
    p_sponsor_name in SPONSOR.SPONSOR_NAME%type,
    p_result out number
) AS

repeated_sponsor_name exception;
pragma exception_init(repeated_sponsor_name,-00001);

BEGIN
    
    update sponsor set sponsor_name = upper(p_sponsor_name) 
    where upper(sponsor_code) = upper(p_sponsor_code);
    
    if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('Sponsor updated successfully');
    else
        p_result := 0;
        dbms_output.put_line('Sponsor not updated');
        
        if sql%notfound then  
            dbms_output.put_line('Invalid Sponsor Code. Code does not exist');
        end if;     
    end if;           
    
    exception
    when repeated_sponsor_name then
        dbms_output.put_line('Sponsor already exists');
    when others then
        dbms_output.put_line('Sorry could not update your record');
        
END UPDATE_SPONSOR;

CREATE OR REPLACE PROCEDURE DELETE_SPONSOR (

    p_sponsor_code in SPONSOR.SPONSOR_CODE%type,
    p_result out number
)AS 

BEGIN
    delete from sponsor where upper(sponsor_code) = upper(p_sponsor_code);
    
    if sql%notfound then
        dbms_output.put_line('Delete failed. Sponsor code does not exist.');
    end if;
    
    if sql%rowcount = 1 then
        dbms_output.put_line('Delete successful');
    end if;
    
END DELETE_SPONSOR;


CREATE OR REPLACE PROCEDURE ADD_PARLIAMENTARY_SESSION (
    p_sess_name in PARLIAMENTARY_SESSION.SESSION_NAME%type,
    p_start_date in PARLIAMENTARY_SESSION.START_DATE%type,
    p_end_date in PARLIAMENTARY_SESSION.END_DATE%type,
    p_result out number
    
)AS 

v_sess_code PARLIAMENTARY_SESSION.SESSION_CODE%type;

repeated_sess_code exception;
pragma exception_init(repeated_sess_code,-00001);

BEGIN
    v_sess_code := 'PSS-00' || PARLIAMENTSQ.NEXTVAL;
    
    insert into parliamentary_session values (v_sess_code, upper(p_sess_name), p_start_date, p_end_date);
    
    if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('Session created successfully');
    else
        p_result := 0;
        dbms_output.put_line('Session not created');
    end if;

    exception
    when repeated_sess_code then
        dbms_output.put_line('Session name already exists');
    when others then
        dbms_output.put_line('Sorry could not create your record');
        
        
END ADD_PARLIAMENTARY_SESSION;


CREATE OR REPLACE PROCEDURE UPDATE_PARLIAMENTARY_SESSION (
    p_sess_code in PARLIAMENTARY_SESSION.SESSION_CODE%type,
    p_sess_name in PARLIAMENTARY_SESSION.SESSION_NAME%type,
    p_start_date in PARLIAMENTARY_SESSION.START_DATE%type,
    p_end_date in PARLIAMENTARY_SESSION.END_DATE%type,
    p_result out number
)AS 

repeated_sess_code exception;
pragma exception_init(repeated_sess_code,-00001);

BEGIN

    update parliamentary_session 
    set session_name = upper(p_sess_name), start_date = p_start_date, end_date = p_end_date
    where upper(session_code) = upper(p_sess_code);

    if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('Parliamentary Session updated successfully');
    else
        p_result := 0;
        dbms_output.put_line('PParliamentary Session not updated');
        
        if sql%notfound then  
            dbms_output.put_line('Invalid Parliamentary Session Code. Code does not exist');
        end if;     
    end if;           
    
    exception
    when repeated_sess_code then
        dbms_output.put_line('Parliamentary Session name already exists');
    when others then
        dbms_output.put_line('Sorry could not update your record');
        
END UPDATE_PARLIAMENTARY_SESSION;

CREATE OR REPLACE PROCEDURE DELETE_PARLIAMENTARY_SESSION (
    p_sess_code in PARLIAMENTARY_SESSION.SESSION_CODE%type,
    p_result out number
)AS 

BEGIN
    delete from parliamentary_session where upper(session_code) = upper(p_sess_code);
    
    if sql%notfound then
        dbms_output.put_line('Delete failed. Parliamentary Session code does not exist.');
    end if;
    
    if sql%rowcount = 1 then
        dbms_output.put_line('Delete successful');
    end if;
    
END DELETE_PARLIAMENTARY_SESSION;


CREATE OR REPLACE PROCEDURE ADD_MP4SESSION (
    p_mpcode in MP4_SESSION.MP_CODE%type,
    p_sess_code in MP4_SESSION.SESSION_CODE%type,
    p_party_code in MP4_SESSION.PARTY_CODE%type,
    p_date_joined in MP4_SESSION.DATE_JOINED%type,
    p_result out number
    
) AS 

double_entry exception;
pragma exception_init(double_entry,-00001);

invalid_code exception;
pragma exception_init(invalid_code,-02291);

BEGIN
    insert into MP4_SESSION values (upper(p_mpcode), upper(p_sess_code), upper(p_party_code), p_date_joined);
    
     if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('Session created successfully');
    else
        p_result := 0;
        dbms_output.put_line('Session not created');
    end if;
    
    exception
    when double_entry then
         dbms_output.put_line('Similar Record already exists');
    when invalid_code then
         dbms_output.put_line('entered code does not exist');
    when others then
        dbms_output.put_line('Sorry could not update your record');
    
    
END ADD_MP4SESSION;

CREATE OR REPLACE PROCEDURE UPDATE_MP4SESSION (
    p_mpcode in MP4_SESSION.MP_CODE%type,
    p_sess_code in MP4_SESSION.SESSION_CODE%type,
    p_party_code in MP4_SESSION.PARTY_CODE%type,
    p_date_joined in MP4_SESSION.DATE_JOINED%type,
    p_result out number
)AS 

BEGIN
    update mp4_session set date_joined = p_date_joined
    where upper(mp_code) = upper(p_mpcode) 
        and upper(session_code) = upper(p_sess_code) 
        and upper(party_code) = upper(p_party_code);
    
    if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('update successfully');
    else
        p_result := 0;
        dbms_output.put_line('no update perfomed');
        
        if sql%notfound then  
            dbms_output.put_line('No record found.');
        end if;     
    end if;
        
    exception
    when others then
        dbms_output.put_line('Sorry could not update your record');
    
END UPDATE_MP4SESSION;


CREATE OR REPLACE PROCEDURE DELETE_MP4SESSION (
    p_mpcode in MP4_SESSION.MP_CODE%type,
    p_sess_code in MP4_SESSION.SESSION_CODE%type,
    p_party_code in MP4_SESSION.PARTY_CODE%type,
    p_result out number
)AS 
BEGIN
    delete from mp4_session 
    where  upper(mp_code) = upper(p_mpcode) 
        and upper(session_code) = upper(p_sess_code) 
        and upper(party_code) = upper(p_party_code);
    
    if sql%notfound then
        dbms_output.put_line('Delete failed. Invalid MP4Session code');
    end if;
    
    if sql%rowcount = 1 then
        dbms_output.put_line('Delete successful');
    end if;
    

END DELETE_MP4SESSION;

create or replace PROCEDURE ADD_BILLS (
    p_billname in BILLS.BILL_NAME%type,
    p_sponsor_code in BILLS.SPONSOR_CODE%type,
    p_bill_date in BILLS.BILL_DATE%type,
    p_bill_status in BILLS.BILL_STATUS%type,
    p_result out number
)AS

v_bill_code constituency.constituency_code%type;

repeated_bill_name exception;
pragma exception_init(repeated_bill_name,-00001);

invalid_sponsor exception;
pragma exception_init(invalid_sponsor,-02291);

--violated check constraint --
invalid_value exception;
pragma exception_init(invalid_value, -02290);

BEGIN
    v_bill_code:='pb-' || to_char(sysdate,'yyyy') || '-00' || PARLIAMENTSQ.NEXTVAL;
    insert into bills values (v_bill_code, upper(p_billname), upper(p_sponsor_code), p_bill_date, upper(p_bill_status));
    
    if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('Bill created successfully');
    else
        p_result := 0;
        dbms_output.put_line('Bill not created');
    end if;

    exception
    when repeated_bill_name then
        dbms_output.put_line('Similar bill name already exists');
    when invalid_sponsor then
        dbms_output.put_line('Invalid sponsor code. Code does not exist');
    when invalid_value then
        dbms_output.put_line('Invalid bill status entered. Should be either pending, yes or no');
    when others then
        dbms_output.put_line('Sorry could not create your record');
        
        
END ADD_BILLS;

CREATE OR REPLACE PROCEDURE UPDATE_BILL (
    p_bill_code in BILLS.BILL_CODE%type,
    p_billname in BILLS.BILL_NAME%type,
    p_sponsor_code in BILLS.SPONSOR_CODE%type,
    p_bill_date in BILLS.BILL_DATE%type,
    p_bill_status in BILLS.BILL_STATUS%type,
    p_result out number
)AS 

repeated_bill_name exception;
pragma exception_init(repeated_bill_name,-00001);

invalid_sponsor exception;
pragma exception_init(invalid_sponsor,-02291);

--violated check constraint --
invalid_value exception;
pragma exception_init(invalid_value, -02290);


BEGIN

    update bills 
    set  bill_name = upper(p_billname), sponsor_code = upper(p_sponsor_code), 
        bill_date = p_bill_date, bill_status = upper(p_bill_status)
    where upper(bill_code) = upper(p_bill_code);
    
    if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('Bill updated successfully');
    else
        p_result := 0;
        dbms_output.put_line('Bill not created');
        if sql%notfound then  
            dbms_output.put_line('Invalid Bill Code');
        end if; 
    end if;

    exception
    when repeated_bill_name then
        dbms_output.put_line('Similar bill name already exists');
    when invalid_sponsor then
        dbms_output.put_line('Invalid sponsor code. Code does not exist');
    when invalid_value then
        dbms_output.put_line('Invalid bill status entered. Should be either pending, yes or no');
    when others then
        dbms_output.put_line('Sorry could not create your record');
        
END UPDATE_BILL;

CREATE OR REPLACE PROCEDURE DELETE_BILL (
    p_bill_code in BILLS.BILL_CODE%type,
    p_result out number
)AS 
BEGIN
    delete from bills where upper(bill_code) = upper(p_bill_code);
    
    if sql%notfound then
        dbms_output.put_line('Delete failed. Invalid Bill code.');
    end if;
    
    if sql%rowcount = 1 then
        dbms_output.put_line('Delete successful');
    end if;
END DELETE_BILL;


CREATE OR REPLACE PROCEDURE ADD_BILL_VOTE(

    p_mpcode in BILL_VOTE.MP_CODE%type,
    p_session_code in BILL_VOTE.SESSION_CODE%type,
    p_party_code in BILL_VOTE.PARTY_CODE%type,
    p_bill_code in BILL_VOTE.BILL_CODE%type,
    p_vote in BILL_VOTE.VOTE%type,
    p_vote_date in BILL_VOTE.VOTE_DATE%type,
    p_result out number
    
) AS 

double_entry exception;
pragma exception_init(double_entry,-00001);

invalid_code exception;
pragma exception_init(invalid_code,-02291);

--violated check constraint --
invalid_value exception;
pragma exception_init(invalid_value, -02290);

BEGIN
    insert into bill_vote values (upper(p_mpcode), upper(p_session_code), upper(p_party_code), upper(p_bill_code), upper(p_vote), p_vote_date);
    
    if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('Bill vote entered successfully');
    else
        p_result := 0;
        dbms_output.put_line('Bill vote not entered');
    end if;
    
    exception
    when double_entry then
         dbms_output.put_line('Similar Record already exists');
    when invalid_code then
         dbms_output.put_line('entered code does not exist');
    when invalid_value then
        dbms_output.put_line('Invalid bill vote entered. Should be either yes, no, absent or abstain');
    when others then
        dbms_output.put_line('Sorry could not create your record');
        
END ADD_BILL_VOTE;


CREATE OR REPLACE PROCEDURE UPDATE_BILL_VOTE (
    p_mpcode in BILL_VOTE.MP_CODE%type,
    p_session_code in BILL_VOTE.SESSION_CODE%type,
    p_party_code in BILL_VOTE.PARTY_CODE%type,
    p_bill_code in BILL_VOTE.BILL_CODE%type,
    p_vote in BILL_VOTE.VOTE%type,
    p_vote_date in BILL_VOTE.VOTE_DATE%type,
    p_result out number
)AS 

double_entry exception;
pragma exception_init(double_entry,-00001);

invalid_code exception;
pragma exception_init(invalid_code,-02291);

--violated check constraint --
invalid_value exception;
pragma exception_init(invalid_value, -02290);

BEGIN
    update BILL_VOTE 
    set vote = upper(p_vote), vote_date = p_vote_date
    where upper(mp_code) = upper(p_mpcode) 
        and upper(session_code) = upper(p_session_code)
        and upper(party_code) = upper(p_party_code)
        and upper(bill_code) = upper(p_bill_code);
    
    if sql%rowcount = 1 then
        p_result := 1;
        dbms_output.put_line('update successfully');
    else
        p_result := 0;
        dbms_output.put_line('no update perfomed');
        
        if sql%notfound then  
            dbms_output.put_line('No record found.');
        end if;     
    end if;
    
    exception
    when double_entry then
         dbms_output.put_line('Similar Record already exists');
    when invalid_code then
         dbms_output.put_line('entered code does not exist');
    when invalid_value then
        dbms_output.put_line('Invalid bill vote entered. Should be either yes, no, absent or abstain');
    when others then
        dbms_output.put_line('Sorry could not create your record');    
    
    
END UPDATE_BILL_VOTE;


CREATE OR REPLACE PROCEDURE DELETE_BILL_VOTE (
    p_mpcode in BILL_VOTE.MP_CODE%type,
    p_session_code in BILL_VOTE.SESSION_CODE%type,
    p_party_code in BILL_VOTE.PARTY_CODE%type,
    p_bill_code in BILL_VOTE.BILL_CODE%type,
    p_result out number
    
)AS 

BEGIN
    delete from bill_vote 
    where upper(mp_code) = upper(p_mpcode) 
        and upper(session_code) = upper(p_session_code)
        and upper(party_code) = upper(p_party_code)
        and upper(bill_code) = upper(p_bill_code);
        
    if sql%notfound then
        dbms_output.put_line('Delete failed. No record found.');
    end if;
    
    if sql%rowcount = 1 then
        dbms_output.put_line('Delete successful');
    end if;
    
END DELETE_BILL_VOTE;


/************************** VIEWS **************************/
create or replace view mp_info as
    select mp_lastname "Last Name", mp_othernames "Other Name", constituency_name "Constituency",
            region_name "Region", Upper(nvl(party_name,'Independent Candidate')) as "Party Affliation"
    from mp m join constituency c on m.constituency_code = c.constituency_code
    join region r on r.region_code = c.region_code
    left join mp4_session s on s.mp_code = m.mp_code
    left join political_party p on p.party_code = s.party_code;
    
create or replace view bill_info as 
    select bill_name "Bill Title", sponsor_name "Sponsor", bill_date "Date Presented", bill_status "Bill Status"
    from bills b join sponsor s on b.sponsor_code = s.sponsor_code
    order by s.sponsor_name;


create or replace view bill_vote_info as 
    select mp_lastname "MP Last Name", mp_othernames "MP Other Name", party_name "Affliated Party", 
        bill_name "Bill Name", sponsor_name "Sponsor", session_name "Session Name", 
        vote_date "Date of Vote", vote "Vote Cast"
    from bill_vote bv join bills b on bv.bill_code = b.bill_code
         join mp on mp.mp_code = bv.mp_code 
         join sponsor s on s.sponsor_code = b.sponsor_code
         join parliamentary_session ps on ps.session_code = bv.session_code
         join mp4_session s on s.mp_code = mp.mp_code
         join political_party p on p.party_code = s.party_code;



