# Real-Time-Data-Streaming-Pipeline

Welcome to the Real-Time Data Streaming Pipeline project.

# Introduction

CERN Technology department, and in particular, vacuum group, makes use of the largest vacuum system in operation in the world. It is monitored and controlled by a large-scale distributed control system, comprised of a wide set of software applications and computing infrastructure.

The set of vacuum SCADA applications used to monitor and control over 100 km of vacuum lines produces a considerable amount of data. Taking into consideration that the vacuum control system produces data for thousands
of pieces of equipment almost at a per second rate, and including other sources of data such as application logs and server metrics, vacuum at CERN can be considered, as per industry terms, as a Big Data producer.

Because this data is being produced locally from multiple independent applications, each with their specificities on data format, connecting external systems to the vacuum
control system to process and analyse real-time data is a difficult task, that can only be accomplished by the development of custom software to interconnect both parties.
To take advantage of the sea of data produced by vacuum, it is therefore necessary to find a common place and data format to stream data, thus opening the way for the development of a new generation of data analysis tools.

The main objective of this project is, therefore, the development of a software and server infrastructure (pipeline) that will be a source of vacuum data for external clients. It allows collecting, processing,
and analysing data being sent in real-time from the servers, but in a centralized manner, so that a further monitoring process can be carried out.


# Contents

This project has been divided into two parts (folders 1 and 2).

First part (1-Log Streaming Pipeline), deals with the real-time streaming of log messages. As a result of this first pipeline, we will be able to gather (all at the same time), logs coming from the different vacuum servers.
This will help experts at vacuum creating their own dashboards with the collected data as well as detecting unexpected situations along the 100 km vacuum lines in the monitoring process.
Main tools and technologies used in this project are: Filebeat, Logstash, Elasticsearch, Kibana, Docker.

Second part (2-SCADA Streaming Pipeline), deals with the real-time streaming of vacuum data (value of pressures, statuses, currents, etc coming from the vacuum equipment).
In this case, this pipeline will detect any change of data in any of the thousands of equipments making up the vacuum system, and stream the new value to Kafka for a further processing.
Since data at vacuum is stored and managed by an industrial tool called WinCC-OA, we will start streaming the data from this point. Two pipeline alternatives have been tested in this case (folders 1-HSE-Kafka Driver and 2-WinCC-OA Ctrl Extension):

  1) WinCC-OA --> HSE-Kafka Driver --> Kafka
  
    Main tools and technologies used in this project are: WinCC-OA, Kafka, Docker, Git.
    
  2) WinCC-OA --> WinCC-OA Ctrl Extension --> Kafka
  
    Main tools and technologies used in this project are: WinCC-OA, CMake, Make, Kafka, Docker, Git.
    
A performance evaluation was carried out to select the most convenient option. This has been performed by means of the extraction of several metrics (delay and throughput) with some Python scripts. This helps us determining the effectiveness of each of the approaches.

If you just want to have a more generic idea of the project's content, you can directly refer to the file "Presentation_Master_Thesis", a presentation summarising all concepts.