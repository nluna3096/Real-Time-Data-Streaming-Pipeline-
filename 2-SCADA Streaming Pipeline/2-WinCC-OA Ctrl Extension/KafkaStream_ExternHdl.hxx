/**
 * C++ CTRL Extension to stream real-time data to Kafka
 * @author Nerea Luna (CERN)
*/

#ifndef __KAFKASTREAM_EXTERNHDL_H_
#define __KAFKASTREAM_EXTERNHDL_H_

#include <BaseExternHdl.hxx>

class KafkaStream_ExternHdl : public BaseExternHdl
{
  public:
    KafkaStream_ExternHdl(BaseExternHdl *nextHdl, PVSSulong funcCount, FunctionListRec fnList[])
      : BaseExternHdl(nextHdl, funcCount, fnList) {}

    virtual const Variable *execute(ExecuteParamRec &param);
};

#endif
