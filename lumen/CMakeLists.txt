cmake_minimum_required(VERSION 3.21)
project(NexusLumen VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick)
qt_standard_project_setup()

qt_add_executable(nexus-lumen main.cpp)
target_link_libraries(nexus-lumen PRIVATE Qt6::Quick)
qt_add_resources(nexus-lumen "lumen_qml"
    PREFIX "/"
    FILES qml/Main.qml
)

install(TARGETS nexus-lumen RUNTIME DESTINATION bin)
