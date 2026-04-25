/* SPDX-License-Identifier: Apache-2.0
 *
 */

 #include <iostream>

int main() {
    std::cout << "Hello from C++! count=" << 42 << std::endl;

#ifdef __EXCEPTIONS
    try {
        throw std::runtime_error("Test exception");
    } catch (const std::exception& e) {
        std::cout << "Caught exception: " << e.what() << std::endl;
    }
#endif

    return 0;
}
