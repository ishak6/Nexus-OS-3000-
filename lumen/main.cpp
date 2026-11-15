#include <cstdlib>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include <QQmlContext>
#include <QUrl>

#include "PulseMonitor.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QCoreApplication::setApplicationName(QStringLiteral("Nexus LUMEN"));
    QCoreApplication::setOrganizationName(QStringLiteral("Nexus OS"));

    PulseMonitor pulseMonitor;
    pulseMonitor.start();

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(
        QStringLiteral("pulseMonitor"), &pulseMonitor);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        [] { QCoreApplication::exit(EXIT_FAILURE); },
        Qt::QueuedConnection);
    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));

    return app.exec();
}
