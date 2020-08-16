### Streaming

In order to use the HSE driver to stream values to Kafka, we should first check three things:

- You have your library files compiled and placed in the corresponding folder. See [Data Pipeline Compilation](compilation.md).

- You are able to start your WCCOAkafkaDrv manager

- You created all files regarding security configuration for accessing the Kafka cluster. See [Data Pipeline Security Configuration for Accessing Kafka cluster](kafka_cluster.md).


If you are done with those requirements, you can proceed to the next section, where we actually stream data to Kafka.