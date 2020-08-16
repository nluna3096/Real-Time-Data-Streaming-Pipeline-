/**
 * Script that automatically reads a configuration file, configures the periphery address and streams real-time values to Kafka in JSON format
 * @file vcsKafkaExport.ctl
 * @author Nerea Luna (CERN)
 * @date   30/03/2020
*/

#uses "vclMachine.ctl"


const unsigned periphAddress_KAFKA_SUBINDEX = 7;
const unsigned DEBOUNCING = 0;


mapping config_mapping; //mapping to access configuration data from inside callback function


main(){

	dyn_string exceptionInfo;
	dyn_anytype jSonResult;
	
	LhcVacGetMachineId(exceptionInfo); // stores machine name into glAccelerator variable

	string configFileName = "./data/" + glAccelerator + "_KafkaStream.config";
	jSonResult = readExportConfigFile(configFileName);

	dyn_string split, periphAddr;
	dyn_anytype valueDpe;
	string targetDP, targetDPE;


	int driverNum = 14; // number used by HSE-CEN group
	int mode = DPATTR_ADDR_MODE_OUTPUT; // mode = 1
	int num_JSON_block = dynlen(jSonResult);

	// We start reading each block (DPE) of the JSON file
	for(int i = 1; i <= num_JSON_block; i++){

		// TARGET DP
		targetDP = jSonResult[i]["kafkaId"];

		// Creates a new DP per JSON configuration block
		createDP(targetDP);

		targetDPE = targetDP + ".valueToKafka"; // ex. "VGI_1025_5L4_B_PR.valueToKafka"

		// Getting TOPIC name from string "vac.<accelerator>.<topic>"
		split = strsplit(jSonResult[i]["topic"], ".");

		// This global mapping will allow accessing the config data from inside the callback()
		config_mapping[jSonResult[i]["sourceDPE"]] = jSonResult[i];

		// VALUE
		// Every time "sourceDPE" changes, "streamToKafka" is called
		dpGet(jSonResult[i]["sourceDPE"] + ":_original.._value", valueDpe);

		// VALUETOKAFKA	(DPE that streams ==> configure periphery address)
		// Getting PERIPHERY ADDRESS in format: <TOPIC$KEY$DEBOUNCING> (KEY = TARGETDP)
		periphAddr[i] = split[3] + "$" + targetDP + "$" + DEBOUNCING;

		// Creates a periphery address
		KAFKA_addressDPE(periphAddr[i], driverNum, targetDPE, mode, exceptionInfo, "");

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
  * Called each time we read a new JSON block from the exporter configuration file
  * Method to automatically creates new DPs
  * @param DP we want to create
  * @return 0 if DP was properly created, -1 if DP already exists
  */
int createDP(string dp){

	if (!dpExists(dp)){ //check if DP already exists
		return dpCreate(dp,"_kafkaExport"); // creates DP from "_kafkaExport" DPT
	}
	else{
		return -1;
	}
}



/**
 * Called when a DPE connected to this driver is adressed (sets its periphery address configuration)
 * @param address string             ex: "pressures$VGI_1025_5L4_B_PR$0"
 * @param driver manager number      ex. 14
 * @param path to the target DPE     ex. "VGI_1025_5L4_B_PR.valueToKafka"
 * @param adressing mode             ex. 1
 * @param exeption lists (in case there are)
 * @return 0 if OK, -1 if not
*/
public int KAFKA_addressDPE(string address, int driverNum, string path, int mode, dyn_string &exceptionInfo, string logsDPE=""){

	dyn_anytype params;

	try
	{

	params[fwPeriphAddress_DRIVER_NUMBER] = driverNum;
	params[fwPeriphAddress_DIRECTION]= mode;
	params[fwPeriphAddress_ACTIVE] = true;
	params[periphAddress_KAFKA_SUBINDEX] = 0;
	params[fwPeriphAddress_DATATYPE] = 1005; // String
	params[fwPeriphAddress_REFERENCE] = address; // "pressures$VGI_1025_5L4_B_PR$0"

    KAFKA_PeriphAddress_set(path, params, exceptionInfo);

	}
	catch
	{
	DebugN("Uncaught exception in KAFKA_addressDPE: " + getLastException());
	return -1;
	}

	return 0;
}



/**
  * Method that sets the addressing from datapoints elements
  * @param datapoint element for which address will be set
  * @param configuration parameteres
  * @param parameter to return exceptions values
  */
private void KAFKA_PeriphAddress_set(string dpe, dyn_anytype configParameters, dyn_string& exceptionInfo){

	int i = 1;

	dyn_string names;
	dyn_anytype values;

	//The driver will already have been checked to see that it is running, so just dpSetWait
	dpSetWait(dpe + ":_distrib.._type", DPCONFIG_DISTRIBUTION_INFO,
						dpe + ":_distrib.._driver", configParameters[fwPeriphAddress_DRIVER_NUMBER]);
	dyn_string errors = getLastError();

	if(dynlen(errors) > 0){
		throwError(errors);
		fwException_raise(exceptionInfo, "ERROR", "Could not create the distrib config.", "");
		return;
	}

	names[i] = dpe + ":_address.._type";
	values[i++] = DPCONFIG_PERIPH_ADDR_MAIN;
	names[i] = dpe + ":_address.._drv_ident";
	values[i++] = "KAFKA Driver";
	names[i] = dpe + ":_address.._reference";
	values[i++] = configParameters[fwPeriphAddress_REFERENCE];
	names[i] = dpe + ":_address.._mode";
	values[i++] = configParameters[fwPeriphAddress_DIRECTION];
	names[i] = dpe + ":_address.._datatype";
	values[i++] = configParameters[fwPeriphAddress_DATATYPE];
	names[i] = dpe + ":_address.._subindex";
	values[i++] = configParameters[periphAddress_KAFKA_SUBINDEX];

	dpSet(names, values); // setting values to periphery address configuration parameters
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
	string message;
	string targetDPE;
	dyn_string split;
	string sector_value, mainpart_value, dcum_value;

	// We split sourceDPE by ":" to extract the source DPE itself
	split = strsplit(sourceDPE, ":"); // ex. "vac_lhc_1", "VGI_1025_5L4_B.PR", "_online.._value"

	sourceDPE = split[2]; // ex. "VGI_1025_5L4_B.PR"

	sector_value = config_mapping[sourceDPE]["sector"];
	mainpart_value = config_mapping[sourceDPE]["mainpart"];
	dcum_value = config_mapping[sourceDPE]["DCUM"];

	// We replace the "." by the "_" in the sourceDPE and concatenate the result to get targetDPE
	strreplace(split[2], ".", "_");
	targetDPE = split[2] + ".valueToKafka";


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

	// In any case, we encode our message and set it to our targetDPE
	message = jsonEncode(dpeData);
	dpSet(targetDPE + ":_original.._value", message);
}