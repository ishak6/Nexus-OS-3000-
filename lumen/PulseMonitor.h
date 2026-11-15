#pragma once

#include <QObject>
#include <QProcess>
#include <QString>

class PulseMonitor final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString cpuUsage READ cpuUsage NOTIFY metricsChanged)
    Q_PROPERTY(QString memoryUsage READ memoryUsage NOTIFY metricsChanged)
    Q_PROPERTY(QString networkUsage READ networkUsage NOTIFY metricsChanged)
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)

public:
    explicit PulseMonitor(QObject *parent = nullptr);
    QString cpuUsage() const;
    QString memoryUsage() const;
    QString networkUsage() const;
    QString status() const;

public slots:
    void start();

signals:
    void metricsChanged();
    void statusChanged();

private slots:
    void consumeOutput();
    void handleProcessError(QProcess::ProcessError error);

private:
    void setStatus(const QString &status);
    QProcess m_process;
    QByteArray m_pending;
    QString m_cpuUsage = QStringLiteral("—");
    QString m_memoryUsage = QStringLiteral("—");
    QString m_networkUsage = QStringLiteral("—");
    QString m_status = QStringLiteral("Waiting for telemetry");
};
