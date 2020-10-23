# Vacuum Data Pipeline - SCADA Streaming Pipeline
---
Welcome to the Vacuum Data Pipeline project.

## Introduction
This project streams data from WinCC-OA to Kafka by means of the development of a CTRL Extension.

## Prerequisites

- This project has been developed in a CC7 machine
- You need to install 3.16 WinCC-OA-devel version (WinCC_OA_3.16-0-20200227.cc7.x86_64.rpm from CERN WinCC-OA downloads page)
- CMake 3.16.1 version (or at least 3.1), which can be installed with:
	
	- ```mkdir -p /home/${USER}/deps/cmake && cd /home/${USER}/deps```
	- ```wget https://github.com/Kitware/CMake/releases/download/v3.16.1/cmake-3.16.1-Linux-x86_64.sh```
	- ```bash cmake-3.16.1-Linux-x86_64.sh --skip-license --prefix=/home/${USER}/deps/cmake```

	- ```ln -s /home/${USER}/deps/cmake/bin/cmake /bin/cmake```
	- ```ln -s /home/${USER}/deps/cmake/bin/ccmake /bin/ccmake```
	- ```ln -s /home/${USER}/deps/cmake/bin/ctest /bin/ctest```

- Compiler:

	- ```yum install gcc-c++```
	- ```gcc --version``` (version 4.8.5)

- External Libraries

	- Clone the HSE Kafka repository:

		- ```export LANGUAGE=en_US.UTF-8```
		- ```export LANG=en_US.UTF-8```
		- ```export LC_ALL=en_US.UTF-8```
		- ```git clone --recurse-submodules https://github.com/cern-hse-computing/WCCOAkafkaDrv.git```

	- Install the boost library as one of the external dependencies:

		- ```sudo yum install --assumeyes cyrus-sasl-gssapi boost* cmake openssl-devel```
		- ```sudo yum install cyrus-sasl-devel.x86_64```

	- Go inside the ```/WCCOAkafkaDrv``` folder and execute the following commands to install librdkafka and cppkafka external libraries:

		- ```cd ./libs/librdkafka && ./configure && make && sudo make install```

	- Go again to ```/WCCOAkafkaDrv``` folder and run the following:

		- ```cd ./libs/cppkafka && mkdir -p build && cd build && cmake .. && make && sudo make install```

## Steps to follow

- Clone this Kafka stream repository to your local machine. Go inside ```/vackafkastream``` folder

	- Execute ```git checkout nerea_branch``` to get the files

- Choose a path where you will compile the CTRL extension, for instance ```/home/${USER}/deps```

- Go to ```/home/${USER}/deps``` and create a folder called "build":

	- ```mkdir build```

- Copy files ```CMakeLists.txt```, ```KafkaStream_ExternHdl.cxx``` and ```KafkaStream_ExternHdl.hxx``` from ```/vackafkastream``` to ```/home/${USER}/deps```

- Open ```CMakeLists.txt``` and replace ```${CMAKE_CURRENT_SOURCE_DIR}``` variable in the last line with your path (```/libs/cppkafka/include``` folder can be found inside the ```/WCCOAkafkaDrv``` folder previously cloned)

- Generate a keytab file for accesing the IT Kafka cluster

- Open ```KafkaStream_ExternHdl.cxx``` file and replace:

	- ```"<your username for connecting to kafka>"``` by your principal name
	- ```"<path to your keytab file>"``` by the path to your already generated keytab file

- Check that your ```$API_ROOT``` variable points to ```/opt/WinCC_OA/3.16/api```

- Go inside ```build``` folder by running ```cd build```

- Run ```cmake ..```

- Run ```make``` (it will generate the library file, called ```VacKafkaStream.so```)

- Copy that generated ```VacKafkaStream.so``` file into your PVSS bin's directory

Up to here, the CTRL Extension part is ready. We will go now through the WinCC-OA side:

- Copy file ```vcsCppKafka.ctl``` from your ```/vackafkastream``` folder into your PVSS script's folder

- In another terminal, run a consumer with a TOPIC name (for instance "vactest"). Leave the consumser waiting for messages

- Open WinCC-OA and add a new Control Manager, taking as parameter the ```vcsCppKafka.ctl``` script. For testing, you can create the manager in "manual mode"

- If you open ```vcsCppKafka.ctl```, you will see that this script takes as input a configuration file (```string configFileName = "./data/" + glAccelerator + "_KafkaStream.config";```)
	- IMPORTANT: check that you have previously created that file, and that the name of the topic in each JSON block inside that file (line ```"topic": "vac.lhc.<TOPIC>",```) coincides with the name of the TOPIC you put as parameter when launching your consumer

- Start the Control Manager: you should see messages arriving to your consumer terminal



## Authors
* **Nerea Luna** 


## License
This project is CERN copyright.
