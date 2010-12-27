
clean	::; rm -f *.log tekChannel_oltp.sql

all	: clean tekChannel_oltp.log 
	  (cd /var/www/html/; buildPhp.pl -module tekchannel_oltp)
