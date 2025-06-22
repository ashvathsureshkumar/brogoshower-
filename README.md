# BrogoShower

An iOS application built with Swift and UIKit.

## Overview

BrogoShower is an iOS app that includes user authentication, calendar functionality, and AI integration using Claude.

## Features

- User registration and login
- Calendar interface
- AI-powered services via Claude
- Modern iOS UI design

## Project Structure

- `Controllers/` - View controllers for login, signup, and main app functionality
- `Views/` - Custom UI components including calendar cells
- `Services/` - Integration services including AI functionality
- `Assets.xcassets/` - App icons, images, and color assets
- `Utils/` - Utility classes and helpers

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+

## Setup

1. Clone the repository
2. Open `brogoshower_part2.xcodeproj` in Xcode
3. Build and run the project

## Architecture

The app follows the MVC (Model-View-Controller) pattern with separate controllers for different screens and a service layer for external integrations.

## AI Integration

This app uses Claude for AI functionality rather than OpenAI services. 