rm -fr questions/*

PAGESIZE=30
MIN=`stat -c %Y .mathse` 
MAX=`date +"%s"`
#MAX=`expr $MIN + 3000`

for f in `find -path "./tags/*" -printf "%f\n"`:
do
	page=1
	totalpages=1
	qno=1
	qno_end=$PAGESIZE

	while [ $page -le $totalpages ]
	do
		echo "Getting page $page"
		wget "http://api.math.stackexchange.com/1.1/questions?body=true&answers=true&comments=true&pagesize=$PAGESIZE&min=$MIN&max=$MAX&page=$page&tagged=$f" -O json.gz
		page=`expr $page + 1`
		
		zcat json.gz > json

		total=`grep \"total\" json | grep "[0-9]*" -o`

		if [ $total -gt 0 ]
		then

			echo "Total Questions : $total"
			totalpages=`expr $total / $PAGESIZE + 1`
			./json_split.py < json
		fi
	done
done

total=`ls -1 questions | wc -l`
echo "Total Questions : $total"

for f in `find questions -name "[0-9]*[0-9]" -printf "%f\n"`:
do
	echo "Processing $f"
	ln -sf questions/$f question.js
	../wkhtmltopdf-i386  -g --window-status Q question.html questions/$f.pdf
done

rm -fr question.js

cd questions
# Generating single big file
gs -q  -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=../MathSE.pdf `ls -v1 *.pdf`

cd ..
# Touch the .mathse file
touch -d "@$MAX" .mathse
