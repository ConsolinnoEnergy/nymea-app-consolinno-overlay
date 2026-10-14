#ifndef CONTROLCONFIGURATIONENUMS_H
#define CONTROLCONFIGURATIONENUMS_H

#include <QObject>

// Mirrors nymea-energy-plugin-consolinno/configurations/controlconfigurationenums.h
// Keep values in sync with the backend - they are transmitted over JSON-RPC
// as the enum key names (operatingMode) respectively as the plain
// OR-combined integer bitmask (optimizationStrategies).

namespace ControlConfig
{
Q_NAMESPACE

enum OperatingMode {
    Systemic = 0,
    ExternalSchedule = 1,
    StrategyControlled = 2,
    Manual = 3,
    NoControl = 4
};
Q_ENUM_NS(OperatingMode)

enum OptimizationStrategy {
    NoStrategy = 0,
    PvOptimized = 1,
    DynamicTariff = 2,
    TimeControlled = 4
};
Q_ENUM_NS(OptimizationStrategy)
Q_DECLARE_FLAGS(OptimizationStrategies, OptimizationStrategy)
Q_FLAG_NS(OptimizationStrategies)

} // namespace ControlConfig

Q_DECLARE_OPERATORS_FOR_FLAGS(ControlConfig::OptimizationStrategies)

#endif // CONTROLCONFIGURATIONENUMS_H
