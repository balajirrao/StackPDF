rm -fr questions/*

PAGESIZE=30
MIN=`stat -c %Y .mathse` 
MAX=`date +\"%s\"`

page=1
totalpages=1
qno=1
qno_end=$PAGESIZE

while [ $page -le $totalpages ]
do
	echo "Getting page $page"
	wget "http://api.math.stackexchange.com/1.1/questions?body=true&answers=true&comments=true&pagesize=$PAGESIZE&min=$MIN&page=$page" -O json.gz

	zcat json.gz > json

	total=`grep \"total\" json | grep "[0-9]*" -o`

	if [ $total = 0 ]
	then
		exit;
	fi

	totalpages=`expr $total / $PAGESIZE + 1`

	if [ $page = $totalpages ]
	then
		qno_end=$total
	else
		qno_end=`expr $qno + $PAGESIZE`
	fi

	while [ $qno -le $qno_end ]
	do
		# Create a javascript variable file #
		echo -n "qdata = " > qdata.js
		head -n1 json >> qdata.js;
		echo \"question_no\" : $qno, >> qdata.js;
		tail -n +2 json >> "qdata.js";

		echo "Generating Question No. $qno"
		../wkhtmltopdf-i386 -q -g --window-status Q question.html  questions/$qno.pdf

		qno=`expr $qno + 1`
	done

	page=`expr $page + 1`
done

# Generating single big file
gs -q  -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=MathSE.pdf questions/*.pdf

# Touch the .mathse file
touch .mathse
