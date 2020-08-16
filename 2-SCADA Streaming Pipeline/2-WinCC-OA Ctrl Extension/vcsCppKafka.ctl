/**
 * Script that automatically reads a configuration file, and streams data to Kafka through the cppkafka library
 * @file vcsCppKafka.ctl
 * @author Nerea Luna (CERN)
 * @date   08/05/2020
*/

#uses "vclMachine.ctl"
#uses "VacKafkaStream"


mapping config_mapping; //mapping to access configuration data from inside callback function

/**
- Read configuration file 
- Every time "sourceDPE" changes, we call "streamToKafka" inside the dpConnect 
- streamToKafka() builds the message with the new value and calls the CTRL extension function (sendKafkaMessage())

*/


main(){

	dyn_anytype jSonResult;
	dyn_string exceptionInfo;

	LhcVacGetMachineId(exceptionInfo); // stores machine name into glAccelerator variable

	string configFileName = "./data/" + glAccelerator + "_KafkaStream.config";

	jSonResult = readExportConfigFile(configFileName);

	dyn_anytype valueDpe;

	int num_JSON_block = dynlen(jSonResult);

	// We start reading each block (DPE) of the JSON file
	for(int i = 1; i <= num_JSON_block; i++){

		//DebugN("SOURCE DPE", jSonResult[i]["sourceDPE"]); // VGAPX_AP411_IP8_VE.PR

		//This global mapping will allow accessing the config data from inside the callback()
		config_mapping[jSonResult[i]["sourceDPE"]] = jSonResult[i];

		// Getting source DPE value
		// Every time "sourceDPE" changes, "streamToKafka" is called
		dpGet(jSonResult[i]["sourceDPE"] + ":_original.._value", valueDpe);

		// Execute callback function
		dpConnect("streamToKafka", jSonResult[i]["sourceDPE"], jSonResult[i]["sourceDPE"] + ":_original.._stime");

	}

}// end main



/**
  * Method that reads each JSON block of the input exporter configuration file
  * and decodes them so that we can access its key-value pairs
  * @param name of the input file to read
  * @return blocks of decoded data
  */
dyn_anytype readExportConfigFile(string fileName){

	file exporterConfig;
	string st;
	blob rtarget;
	int err;

	// Opening exporterConfig file, which is encoded in JSON format
	exporterConfig = fopen(fileName, "r");
	err = ferror(exporterConfig); //output possible errors

	// Checking if there was an error when opening the config file
	if (err){
		DebugN("Error number ",err," while opening configuration file");
	}

	// Moving pointer to end of the file to get its size
	fseek(exporterConfig, 0, SEEK_END);
	long fsize = ftell(exporterConfig); // current value of the file position ("file size")
	fseek(exporterConfig, 0, SEEK_SET); // moving pointer again to beginning of file

	// Reads bytes from exporterConfig and stores into rtarget
	int fr = fread(exporterConfig, rtarget, fsize); // returns number of read characters into rtarget, 5b a 7b a 20 20 22 6b...

	// Reads value from rtarget and stores it into st
	blobGetValue(rtarget, 0, st, fsize);

	// We decode and return the JSON data blocks so that we can access to the key-value pairs
	return jsonDecode(st);

}




/**
  * CALLBACK FUNCTION - executed each time a new source value changes
  * @param source datapoint element
  * @param new value to stream
  * @param time datapoint element
  * @param current timestamp value
  */
void streamToKafka(string sourceDPE, dyn_anytype valueDpe, string stimeDpe, time stime){

	mapping dpeData;
	string message, topic;
	dyn_string split;
	string sector_value, mainpart_value, dcum_value;

	// We split sourceDPE by ":" to extract the source DPE itself
	split = strsplit(sourceDPE, ":"); // ex. "vac_lhc_1", "VGI_1025_5L4_B.PR", "_online.._value"

	sourceDPE = split[2]; // ex. "VGI_1025_5L4_B.PR"

	sector_value = config_mapping[sourceDPE]["sector"];
	mainpart_value = config_mapping[sourceDPE]["mainpart"];
	dcum_value = config_mapping[sourceDPE]["DCUM"];

	// Getting TOPIC name from string "vac.<accelerator>.<topic>"
	topic = config_mapping[sourceDPE]["topic"];
	split = strsplit(topic, ".");
	topic = split[3];

	
	// If DPE has validityBit field defined
	// config_mapping[sourceDPE] refers to the JSON block associated to that DPE
	if(mappingHasKey(config_mapping[sourceDPE], "validityBit")){

		bit32 sourceDpeBit;
		uint value_bit;

		dpGet(sourceDPE + ":_original.._value", sourceDpeBit);
		value_bit = getBit(sourceDpeBit,config_mapping[sourceDPE]["validityBit"]);

		// Build the JSON string, which will be the message to be streamed
		dpeData = makeMapping("id", sourceDPE, "value", valueDpe, "validityBit", value_bit, "timestamp", stime, "sector", sector_value, "mainpart", mainpart_value, "DCUM", dcum_value);

	}
	else{ // DPE has not validityBit defined

		dpeData = makeMapping("id", sourceDPE, "value", valueDpe, "timestamp", stime, "sector", sector_value, "mainpart", mainpart_value, "DCUM", dcum_value);

	}

	// In any case, we encode our message
	message = jsonEncode(dpeData);
	// Call CTRL Extension
	sendKafkaMessage(message, topic);

}