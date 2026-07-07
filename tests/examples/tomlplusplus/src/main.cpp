import tomlplusplus;
import std;

int main() {
    // Parse TOML from string
    auto config = toml::parse(R"(
        [server]
        port = 8080
        host = "localhost"
    )");
    
    // Access values
    auto port = config["server"]["port"].value<int>();
    auto host = config["server"]["host"].value<std::string>();
    
    // Verify
    bool ok = (port.value_or(0) == 8080) && 
              (host.value_or("") == "localhost");
    
    std::println("toml++ test: {}", ok ? "OK" : "FAILED");
    return ok ? 0 : 1;
}
