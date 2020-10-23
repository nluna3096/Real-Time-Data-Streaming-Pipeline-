### How to run a Kafka consumer

The objective of launching a Kafka consumer is checking if messages sent by WinCC-OA Kafka driver are received by it, which will imply data is correctly stored in the corresponding Kafka topic.

For doing so, it is necessary to first download Kafka and make some configurations. Go to ```/home/<user>/kafka``` and execute the following:

```
 sudo yum install wget	
 wget https://archive.apache.org/dist/kafka/2.0.0/kafka_2.12-2.0.0.tgz  
 tar -xzf kafka_2.12-2.0.0.tgz
```

With Kafka already downloaded, go to ```/home/<user>/kafka/kafka_2.12-2.0.0``` and add these lines in the consumer configuration file by running the following:

```
 echo "
security.protocol=SASL_SSL
sasl.mechanism=GSSAPI
sasl.kerberos.service.name=kafka" >> config/consumer.properties
```

In order to access the Kafka cluster provided by IT department, you should create a request in [CERN Service-Now](https://cern.service-now.com/service-portal/service-element.do?name=Streaming-Data-Services). After that, you can log in with your account in [IT Kafka cluster](https://kafka.web.cern.ch/) and manage your Kafka topics there.

We also need to create a Kafka topic to which our data will be sent and stored in Kafka. Hence, go to [IT Kafka cluster](https://kafka.web.cern.ch/) and log in with your account. Then, click on "Topic Configuration" and fill in the "Name", "#Partitions", "Replication Factor" and "E-Group". You can set the configuration you desire, but for the "E-Group" field, you need to specify "vac-kafka-users". Notice you need to give permissions to write into that topic (can be configured in “Topic Acls” tab, where the “Principal” field should be set to ```egroup:vac-kafka-users``` and “Operation” to ALL).

In order to run a consumer, execute the following command from ```/home/<user>/kafka/kafka_2.12-2.0.0```:

``` ./bin/kafka-console-consumer.sh --bootstrap-server $KAFKA_NODES --from-beginning --consumer.config config/consumer.properties --topic <your_topic_name>```

The consumer will start and wait for messages (you will not see anything in the console unless we start the WinCC-OA manager and make some configurations, so just leave the consumer waiting for messages and continue the tutorial).

Just in case your project requires so (not in this tutorial), we can also configure a Kafka producer in the same way we did with the consumer. The following lines should be added into the producer configuration file (```/home/<user>/kafka/kafka_2.12-2.0.0/config/producer.properties```):

```
echo "
security.protocol=SASL_SSL
sasl.mechanism=GSSAPI
sasl.kerberos.service.name=kafka" >> config/producer.properties
```

And you should run the following:

``` ./bin/kafka-console-producer.sh --broker-list $KAFKA_NODES --producer.config config/producer.properties --topic <your_topic_name>```