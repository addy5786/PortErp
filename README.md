#Port Management Enterprise Resource Planning (ERP) System

A robust, web-based multi-role application designed to digitise, streamline, and centralise end-to-end commercial port operations. This platform replaces manual and siloed workflows with a unified, role-driven interface ensuring data integrity, high operational visibility, and regulatory traceability.

📋 Table of Contents

Project Overview

Operational Modules & System Architecture

User Roles & Access Control (RBAC)

Database Schema Summary

Tech Stack & Standards

Non-Functional Requirements

Getting Started / Installation

Future Roadmap (v2.0)

🚢 Project Overview

The Port Management ERP provides real-time oversight and operational execution across core maritime domains:

Ship Lifecycle: Track arrivals, departures, operator assignments, and statuses (Anchored, Docked, Departed).

Berth & Dock Scheduling: Real-time dock allocation management with conflict prevention for overlapping windows.

Cargo & Container Logistics: Container classification (Dry, Reefer, Open Top, Tank) and granular cargo movement tracking (Load, Unload, Transfer).

Security & Compliance: Secure user identity management, activity logging, and robust session management.

🧩 Operational Modules & System Architecture

The application is structured around 11 core interface modules:

Login & Authentication: Secure gateway with encrypted password storage and session enforcement.

Dashboard: Role-tailored operational landing views providing stat cards and quick actions.

User Management: Admin-only interface for creating, updating, assigning roles, and deactivating accounts.

Ship Management: Full vessel registry featuring search, pagination, and status management.

Dock Management: Visual dock status board displaying berth availability and maintenance indicators.

Dock Allocation: Multi-step workflow for assigning ships to docks for defined time windows.

Container Management: Registry tracking container types, assignments, and associated cargo contents.

Cargo Management: Inventory tracker capturing cargo descriptions, weights, and container mapping.

Cargo Movement: Audit log for recording individual load, unload, and transfer events with timestamp and handler attribution.

Security Log: Tabular audit view for tracking user sessions, login/logout timestamps, and duration (Exportable to CSV).

Profile & Settings: Self-service user account management and password updates.

👤 User Roles & Access Control (RBAC)

Role

Core System Responsibilities

Administrator

Full system access; manages user accounts, roles, platform setup, and security logs.

Port Manager

Oversees all operational modules, generates compliance reports, and views audit logs.

Ship Operator

Registers incoming vessels, updates ship statuses, and associates containers.

Dock Manager

Maintains dock records, configures availability boards, and handles dock allocations.

Cargo Handler

Records cargo inventory and logs granular loading/unloading movement events.

🗄️ Database Design Summary

The relational database schema is normalised to Third Normal Form (3NF) with enforced foreign key constraints:

ROLE: Defines system access levels.

USER: Stores credentials (hashed via bcrypt/Argon2) and role bindings.

SHIP: Tracks vessel schedules, operators, and current status.

DOCK: Manages berth codes and operational availability.

DOCK_ALLOCATION: Relates ships to docks across specific time windows.

CONTAINER: Classifies standard container units linked to vessels.

CARGO: Inventory items contained within specific units.

CARGO_MOVEMENT: Detailed chronological log of handling operations.

SECURITY_LOG: Session history tracker for security compliance.

🛠️ Tech Stack & Standards

Frontend: Bootstrap 5 UI Component Library, Responsive HTML5/CSS3, JavaScript.

Backend Architecture: Modular Model-View-Controller (MVC) with a clear API separation layer.

Database Management System: Relational DBMS (MySQL / PostgreSQL / Equivalent).

Compliance & Guidelines:

IEEE Std 830-1998 (SRS Standards)

ISO/IEC 25010:2011 (Quality Requirements)

OWASP Security Guidelines for Web Applications

🔒 Non-Functional Requirements

Security: Strict HTTPS/TLS 1.2+ enforcement, cryptographic password hashing, automated 30-minute idle session timeouts, and server-side RBAC validation.

Performance: Target page load under 2 seconds; support for $\ge 50$ concurrent users; indexed query response times under 500ms.

Reliability: Target 99.5% uptime during operational hours (06:00 – 22:00 local time) with daily automated database backups retained for 30 days.

🚀 Getting Started / Installation

Clone the Repository:

git clone https://github.com/your-username/port-management-erp.git
cd port-management-erp


Database Setup:

Provision a relational database (MySQL/PostgreSQL).

Execute the schema creation scripts matching the 3NF database layout specifications.

Configure Environment Variables:

Set up database connection strings, application secrets, and server ports in your .env configuration file.

Run the Application:

Launch the backend server and serve the frontend files through a secure web server.

🔮 Future Roadmap (v2.0)

Automated manifest generation and customs declaration PDF exports.

Real-time push notifications (email/SMS) for dock availability and vessel alerts.

Multi-facility support for port networks spanning multiple geographic locations.

Advanced analytics dashboard with historical trend visualisation.

Mobile companion application tailored for field-based Cargo Handlers.

Port Management ERP v1.0 — Digitising and streamlining maritime logistics.
