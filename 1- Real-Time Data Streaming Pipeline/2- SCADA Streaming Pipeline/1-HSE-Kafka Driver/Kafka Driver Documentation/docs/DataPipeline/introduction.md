# Data Pipeline SCADA Streaming Technical Guide
*Author: Nerea Luna*

## Introduction

The objective of the vacuum Data Pipeline project is the development of an infrastructure that allows for seamless integration between the vacuum SCADA and potential consumers, with the objective of extracting value from raw vacuum data.

Due to its ability to integrate with consumers written on many programming languages, its potential for scalability, and performance, Kafka as been chosen as the streaming platform. This guide explains the necessary steps to configure vacuum WinCC-OA applications to stream data to Kafka, and the architecture behind its configuration.

This guide is focused on providing a detailed explanation for setting up and validating all of the required infrastructure.

The components used in this SCADA streaming data pipeline are the following:

- **Configuration file:** it consists of a configuration file that stores information about each vacuum source DPE. This file is written in JSON format, and will be ingested by a WinCC-OA CTRL script in further steps within the pipeline.

- **WinCC-OA:** in WinCC-OA, functionalities are handled by managers, independent programs that provide specific functionalities such as historical archiving and periphery communication. Vacuum data is streamed to Kafka with a WinCC-OA Kafka manager, developed at CERN by the HSE group.

- **Kafka HSE Driver:** a WinCC-OA specific driver used to stream and/or ingest data via Kafka. This component will be integrated into the WinCC-OA tool through a manager.

- **Kafka:** a distributed platform for streaming data in real-time. Streamed values from WinCC-OA are stored in “topics” inside Kafka. Consumers subscribe to topics, where they can process the data to gain insights, or send them to other tools from where we can visualize and extract meaningful information.