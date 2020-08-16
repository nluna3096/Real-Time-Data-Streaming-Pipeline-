/**
 * C++ CTRL Extension to stream real-time data to Kafka
 * @author Nerea Luna (CERN)
*/

#include <KafkaStream_ExternHdl.hxx>
#include <cppkafka/cppkafka.h>

#include <string>
#include <TextVar.hxx>

//------------------------------------------------------------------------------
using namespace std;
using namespace cppkafka;


// FunctionListRec is an struct containing 4 fields
static FunctionListRec fnList[] =
{
  { NOTYPE_VAR, "sendKafkaMessage", "(string message, string topic)", false }  
};


// Creates the factory function. (CLASS, funcList)
CTRL_EXTENSION(KafkaStream_ExternHdl, fnList)

// Class to init the producer
class Initializator{
	private:
		Configuration config;
		Producer producer;
	public:
	Initializator():
		// Specific configuration for accessing IT Kafka cluster (missing to read from external file)
		config{
		{ "metadata.broker.list", "dbnile-kafka-a-8.cern.ch:9093,dbnile-kafka-b-8.cern.ch:9093,dbnile-kafka-c-8.cern.ch:9093" },
		{ "security.protocol", "SASL_SSL" },		
		{ "sasl.mechanisms", "GSSAPI" },
		{ "sasl.kerberos.service.name", "kafka" },
		{ "sasl.kerberos.principal", "<your username for connecting to kafka>" },
		{ "sasl.kerberos.keytab", "<path to your keytab file>" },
		{"debug", "all"}}, 
		producer{config}{
			
		}
	
	void send(std::string topic, std::string message){
		// Send the message to specific topic
		producer.produce(MessageBuilder(topic).payload(message));	

		
	}
};
	
// Initialise our producer
Initializator my_producer{};	


//------------------------------------------------------------------------------
// ExecuteParamRec is an struct of 5 fields, one of them is: ExprList *args;
const Variable *KafkaStream_ExternHdl::execute(ExecuteParamRec &param)
{

	param.thread->clearLastError();

	// Read first argument of the CTRL Extension function
	TextVar message_arg;
	message_arg = *(param.args->getFirst()->evaluate(param.thread));
	std::string message = message_arg.getValue();

	// Read second argument of the CTRL Extension function
	TextVar topic_arg;
	topic_arg = *(param.args->getNext()->evaluate(param.thread));
	std::string topic = topic_arg.getValue();

	// Call method to actually send the message
	my_producer.send(topic, message);
	return NULL;
 
}


