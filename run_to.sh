

function la_run {
	qsub -v "LAPARAMS=$LAPARAMS" submit_lamodel.sh
	#./lamodel $LAPARAMS  
	#sleep 1
}


altparams=""
Suffix="REP"
CmdParams="-R -P 4 -p 13 "

for ws in 120;  do
	for BT in 0 5 10 15 20;  do
		for run in  {0..5}; do
			
			LAPARAMS=" -o nBranchesTurnover=${BT} ${CmdParams}  -T $ws -S 191$run -s ${Suffix}G_${BT}_${run} -G"
			la_run

			LAPARAMS=" -o nBranchesTurnover=${BT} ${CmdParams}  -T $ws -S 191$run -s ${Suffix}L_${BT}_${run} -L"
			la_run

			LAPARAMS=" -o nBranchesTurnover=${BT} ${CmdParams}  -T $ws -S 191$run -s ${Suffix}GN_${BT}_${run} -G -n"
			la_run

			LAPARAMS=" -o nBranchesTurnover=${BT} ${CmdParams}  -T $ws -S 191$run -s ${Suffix}LN_${BT}_${run} -L -n"
			la_run

		done
	done
done



