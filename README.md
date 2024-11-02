# Mockable Test Automation System

This project provides a fully mockable test automation framework for iOS mobile app.

## Overview

The modern app are usually sensitive to network conditions and can lead to inconsistent test outcomes. This automation framework eliminates network interference by using mock data, resulting in stable and reliable testing.

### Key Features
- **Mock Server with Request Interceptor**: Use Method-Swizzling to intercept incoming network requests.
- **Local UDP Server & Client Connection**: Enable test suite inject mock data, send mock requests to interceptor, and reaplce the the real networking requests with mocking one, ensuring a stable test environment.
- **Page Object Model (POM)**: Automates UI element management for efficient and reusable UI tests.
- **Dynamic API Response Mocking**: Uses JSON files to simulate various API responses.

## Getting Started

### Prerequisites
- **Xcode** (version compatible with Swift and Objective-C runtime)
- **iOS device** or **simulator**

### Installation
1. Clone this repository.
   ```bash
   git clone <repository_url>
