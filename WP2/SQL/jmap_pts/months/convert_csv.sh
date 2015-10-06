FILES = $PWD/*out

for f in $FILES 
do
 sed -e 's/^[ \t]*//' -e 's/[ \t]*$//' $f > temp.out
 sed -i .bk 's/ \{1,\}/,/g' temp.out
 mv temp.out $(basename $f .out).csv
done

rm temp.out.bk

