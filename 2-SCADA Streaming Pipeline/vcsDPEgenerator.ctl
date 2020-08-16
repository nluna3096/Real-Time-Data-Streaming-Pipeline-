/**
 * Script that automatically generates a Kafka export configuration file from vacuum data in JSON format
 * @file vcsDPEgenerator.ctl
 * @author Nerea Luna (CERN)
 * @date   20/04/2020
*/

#uses "vclMachine.ctl"

main(){

	dyn_string exceptionInfo;

	LhcVacGetMachineId(exceptionInfo);
	//DebugN("glAccelerator", glAccelerator); // Example: "LHC"

	string config_file = "./data/" + glAccelerator + "_KafkaStream.config";
	file writeFile = fopen(config_file, "w");

	int err = ferror(writeFile); // output possible errors
	if(err){
		DebugN("Error number ",err," while opening configuration file");
		return;
	}

	dyn_string dpts;
	dyn_string dpes_PR;
	dyn_string dpes_RR1;
	dyn_string split;
	string targetDPE;
	string sourceDPE;

	dpts = dpTypes(); // returns all DPTs. Ex. "VGI"

	// Getting all PR and RR1 DPEs
	dpes_PR = dpNames("*.PR");
	dpes_RR1 = dpNames("*.RR1");


	/******************************* PR DPEs **********************************/

	for (int i=1; i<= sizeof(dpes_PR); i++){

		split = strsplit(dpes_PR[i], ":");
		sourceDPE = split[2];
		strreplace(split[2], ".", "_");
		targetDPE = split[2];

		if (i == 1){ // first JSON block
			fputs("[" + "\n", writeFile);
			fputs("{" + "\n", writeFile);
			fputs("\"kafkaId\"" + ":" + " " + "\"" + targetDPE + "\"" + "," + "\n", writeFile);
			fputs("\"topic\"" + ":" + " " + "\"" + "vac.lhc."<your_topic_name>"" + "\"" + "," + "\n", writeFile);
			fputs("\"type\"" + ":" + " " + "\"" + "float" + "\"" + "," + "\n", writeFile);
			fputs("\"sourceDPE\"" + ":" + " " + "\"" + sourceDPE + "\"" + "," + "\n", writeFile);
			fputs("\"validityDPE\"" + ":" + " " + "\"" + sourceDPE + "\"" + "," + "\n", writeFile);
			fputs("\"sector\"" + ":" + " " + "\"" + "VACSECPR123" + "\"" + "," + "\n", writeFile);
			fputs("\"mainpart\"" + ":" + " " + "\"" + "LSS1" + "\"" + "," + "\n", writeFile);
			fputs("\"DCUM\"" + ":" + " " + "\"" + "125" + "\"" + "\n", writeFile);
			fputs("}" + "," + "\n", writeFile);
		}
		else{ // rest of cases
			fputs("{" + "\n", writeFile);
			fputs("\"kafkaId\"" + ":" + " " + "\"" + targetDPE + "\"" + "," + "\n", writeFile);
			fputs("\"topic\"" + ":" + " " + "\"" + "vac.lhc."<your_topic_name>"" + "\"" + "," + "\n", writeFile);
			fputs("\"type\"" + ":" + " " + "\"" + "float" + "\"" + "," + "\n", writeFile);
			fputs("\"sourceDPE\"" + ":" + " " + "\"" + sourceDPE + "\"" + "," + "\n", writeFile);
			fputs("\"validityDPE\"" + ":" + " " + "\"" + sourceDPE + "\"" + "," + "\n", writeFile);
			fputs("\"sector\"" + ":" + " " + "\"" + "VACSECPR123" + "\"" + "," + "\n", writeFile);
			fputs("\"mainpart\"" + ":" + " " + "\"" + "LSS1" + "\"" + "," + "\n", writeFile);
			fputs("\"DCUM\"" + ":" + " " + "\"" + "125" + "\"" + "\n", writeFile);
			fputs("}" + "," + "\n", writeFile);
		}
	}



	/******************************* RR1 DPEs **********************************/

	for (int i=1; i<= sizeof(dpes_RR1); i++){

		split = strsplit(dpes_RR1[i], ":");
		sourceDPE = split[2];
		strreplace(split[2], ".", "_");
		targetDPE = split[2];


		if(i == sizeof(dpes_RR1)){ // last JSON block
			fputs("{" + "\n", writeFile);
			fputs("\"kafkaId\"" + ":" + " " + "\"" + targetDPE + "\"" + "," + "\n", writeFile);
			fputs("\"topic\"" + ":" + " " + "\"" + "vac.lhc.statuses" + "\"" + "," + "\n", writeFile);
			fputs("\"type\"" + ":" + " " + "\"" + "unsigned" + "\"" + "," + "\n", writeFile);
			fputs("\"sourceDPE\"" + ":" + " " + "\"" + sourceDPE + "\"" + "," + "\n", writeFile);
			fputs("\"validityDPE\"" + ":" + " " + "\"" + sourceDPE + "\"" + "," + "\n", writeFile);
			fputs("\"validityBit\"" + ":" + " " + "\"" + 30 + "\"" + "," + "\n", writeFile);
			fputs("\"sector\"" + ":" + " " + "\"" + "VACSECRR1123" + "\"" + "," + "\n", writeFile);
			fputs("\"mainpart\"" + ":" + " " + "\"" + "LSS4" + "\"" + "," + "\n", writeFile);
			fputs("\"DCUM\"" + ":" + " " + "\"" + "130" + "\"" + "\n", writeFile);
			fputs("}" + "\n", writeFile);
			fputs("]" + "\n", writeFile);
		}
		else{ // rest of cases
			fputs("{" + "\n", writeFile);
			fputs("\"kafkaId\"" + ":" + " " + "\"" + targetDPE + "\"" + "," + "\n", writeFile);
			fputs("\"topic\"" + ":" + " " + "\"" + "vac.lhc.statuses" + "\"" + "," + "\n", writeFile);
			fputs("\"type\"" + ":" + " " + "\"" + "unsigned" + "\"" + "," + "\n", writeFile);
			fputs("\"sourceDPE\"" + ":" + " " + "\"" + sourceDPE + "\"" + "," + "\n", writeFile);
			fputs("\"validityDPE\"" + ":" + " " + "\"" + sourceDPE + "\"" + "," + "\n", writeFile);
			fputs("\"validityBit\"" + ":" + " " + "\"" + 30 + "\"" + "," + "\n", writeFile);
			fputs("\"sector\"" + ":" + " " + "\"" + "VACSECRR1123" + "\"" + "," + "\n", writeFile);
			fputs("\"mainpart\"" + ":" + " " + "\"" + "LSS4" + "\"" + "," + "\n", writeFile);
			fputs("\"DCUM\"" + ":" + " " + "\"" + "130" + "\"" + "\n", writeFile);
			fputs("}" + "," + "\n", writeFile);
		}
	}

}