#pragma once

#include <Interpreters/StorageID.h>

namespace DB
{

/// Concurrent primitive for dependency completeness registration
/// When arrive methods return true, dependent task must be executed (or scheduled)
/// TODO: Doesn't need to be thread safe.
class RefreshAllCombiner
{
public:
    RefreshAllCombiner();

    explicit RefreshAllCombiner(const std::vector<StorageID> & parents);

    bool arriveTime();

    bool arriveParent(const StorageID & id);

    void flush();

private:
    bool allArrivedLocked();

    void flushLocked();

    std::mutex combiner_mutex;
    std::unordered_map<UUID, bool> parents_arrived;
    bool time_arrived;
};

}
