#include "PulseMonitor.h"

#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QProcessEnvironment>

PulseMonitor::PulseMonitor(QObject *parent)
    : QObject(parent)
{
    connect(&m_process, &QProcess::readyReadStandardOutput,
            this, &PulseMonitor::consumeOutput);
    connect(&m_process, &QProcess::errorOccurred,
            this, &PulseMonitor::handleProcessError);
    connect(&m_process, &QProcess::finished, this,
            [this](int exitCode, QProcess::ExitStatus exitStatus) {
        if (exitStatus == QProcess::CrashExit || exitCode != 0) {
            setStatus(QStringLiteral("Telemetry stopped unexpectedly"));
        } else {
            setStatus(QStringLiteral("Telemetry stopped"));
        }
    });
}

QString PulseMonitor::cpuUsage() const { return m_cpuUsage; }
QString PulseMonitor::memoryUsage() const { return m_memoryUsage; }
QString PulseMonitor::networkUsage() const { return m_networkUsage; }
QString PulseMonitor::status() const { return m_status; }

void PulseMonitor::setStatus(const QString &status)
{
    if (m_status == status)
        return;
    m_status = status;
    emit statusChanged();
}

void PulseMonitor::start()
{
    if (m_process.state() != QProcess::NotRunning)
        return;

    const QString installedScript =
        QStringLiteral("/usr/lib/nexus/pulse/telemetry.py");
    const QString developmentScript = QDir(
        QCoreApplication::applicationDirPath()).filePath(
            QStringLiteral("../../pulse/telemetry.py"));
    const QString script = QFileInfo::exists(installedScript)
        ? installedScript : QDir::cleanPath(developmentScript);

    if (!QFileInfo(script).isFile()) {
        setStatus(QStringLiteral("Telemetry service unavailable"));
        return;
    }

    m_process.setProgram(QStringLiteral("/usr/bin/python3"));
    m_process.setArguments({script, QStringLiteral("--interval"),
                            QStringLiteral("1")});
    m_process.setProcessChannelMode(QProcess::SeparateChannels);
    m_process.start();
    setStatus(QStringLiteral("Starting local read-only telemetry"));
}

void PulseMonitor::consumeOutput()
{
    m_pending.append(m_process.readAllStandardOutput());
    while (true) {
        const qsizetype newline = m_pending.indexOf('\n');
        if (newline < 0)
            break;
        const QByteArray line = m_pending.left(newline).trimmed();
        m_pending.remove(0, newline + 1);
        if (line.isEmpty())
            continue;

        QJsonParseError error;
        const QJsonDocument document = QJsonDocument::fromJson(line, &error);
        if (error.error != QJsonParseError::NoError || !document.isObject()) {
            setStatus(QStringLiteral("Invalid telemetry response"));
            continue;
        }

        const QJsonObject root = document.object();
        if (!root.value(QStringLiteral("read_only")).toBool()) {
            setStatus(QStringLiteral("Rejected non-read-only telemetry"));
            continue;
        }

        const QJsonObject cpu = root.value(QStringLiteral("cpu")).toObject();
        const QJsonValue cpuValue = cpu.value(
            QStringLiteral("usage_percent_since_previous_sample"));
        if (cpuValue.isDouble()) {
            m_cpuUsage = QStringLiteral("%1%").arg(cpuValue.toDouble(), 0, 'f', 1);
        }

        const QJsonObject memory = root.value(QStringLiteral("memory")).toObject();
        const QJsonValue memoryPercent = memory.value(QStringLiteral("used_percent"));
        if (memoryPercent.isDouble()) {
            m_memoryUsage = QStringLiteral("%1%").arg(
                memoryPercent.toDouble(), 0, 'f', 1);
        }

        const QJsonObject network = root.value(QStringLiteral("network")).toObject();
        const QJsonObject deltas = network.value(QStringLiteral("deltas")).toObject();
        qint64 bytesPerInterval = 0;
        for (auto it = deltas.begin(); it != deltas.end(); ++it) {
            const QJsonObject interface = it.value().toObject();
            bytesPerInterval += static_cast<qint64>(
                interface.value(QStringLiteral("rx_bytes_per_interval")).toDouble());
            bytesPerInterval += static_cast<qint64>(
                interface.value(QStringLiteral("tx_bytes_per_interval")).toDouble());
        }
        const double kibibytes = static_cast<double>(bytesPerInterval) / 1024.0;
        m_networkUsage = QStringLiteral("%1 KiB/s").arg(kibibytes, 0, 'f', 1);
        setStatus(QStringLiteral("Live · local procfs"));
        emit metricsChanged();
    }
}

void PulseMonitor::handleProcessError(QProcess::ProcessError error)
{
    if (error == QProcess::FailedToStart)
        setStatus(QStringLiteral("Could not start Python telemetry"));
    else
        setStatus(QStringLiteral("Telemetry process error"));
}
