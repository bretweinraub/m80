
drop function appointment_i () cascade;

create function appointment_i () RETURNS TRIGGER  AS '
	BEGIN
		NEW.INSERTED_DT = now();
		select nextval(''appointment_s'') into NEW.appointment_id;
		RETURN NEW;
	END;
' LANGUAGE 'plpgsql';

create trigger appointment_i before insert on appointment for each row execute procedure appointment_i();


