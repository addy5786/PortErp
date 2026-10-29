# 🚢 Port Management Enterprise Resource Planning (ERP) System

A robust, web-based, multi-role application designed to digitize, streamline, and centralize end-to-end commercial port operations. This platform replaces manual and siloed workflows with a unified, role-driven interface that supports data integrity, operational visibility, and regulatory traceability.

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Operational Modules](#-operational-modules)
- [User Roles and Access Control](#-user-roles-and-access-control-rbac)
- [Database Design](#-database-design-summary)
- [Technology Stack](#-technology-stack-and-standards)
- [Non-Functional Requirements](#-non-functional-requirements)
- [Getting Started](#-getting-started)
- [Future Roadmap](#-future-roadmap-v20)
- [Author](#-author)

## 🚢 Project Overview

The **Port Management ERP System** provides centralized oversight and operational management across core maritime domains.

Key capabilities include:

- **Ship Lifecycle Management:** Track vessel arrivals, departures, operator assignments, and statuses such as Anchored, Docked, and Departed.
- **Berth and Dock Scheduling:** Manage dock allocations and prevent scheduling conflicts across overlapping time windows.
- **Cargo and Container Logistics:** Manage container classifications, cargo inventories, and cargo movement activities.
- **Security and Compliance:** Support user identity management, access control, activity logging, and session management.

## 🧩 Operational Modules

The application is organized into 11 core modules:

1. **Login and Authentication:** Provides a secure login interface and session management.
2. **Dashboard:** Displays role-based operational summaries, statistics, and quick actions.
3. **User Management:** Allows administrators to create, update, assign roles, and deactivate user accounts.
4. **Ship Management:** Maintains vessel records, search functionality, pagination, and ship statuses.
5. **Dock Management:** Displays dock availability, operational status, and maintenance information.
6. **Dock Allocation:** Supports assigning ships to docks for specified time windows.
7. **Container Management:** Maintains container records, types, vessel assignments, and associated cargo.
8. **Cargo Management:** Tracks cargo descriptions, weights, inventory, and container associations.
9. **Cargo Movement:** Records loading, unloading, and transfer activities with timestamps and handler details.
10. **Security Log:** Tracks user sessions, login and logout timestamps, and session durations, with CSV export support.
11. **Profile and Settings:** Supports account management and password updates.

## 👥 User Roles and Access Control (RBAC)

The system defines five user roles with responsibilities aligned to port operations.

| Role | Responsibilities |
|---|---|
| **Administrator** | Manages user accounts, roles, platform configuration, and security logs. |
| **Port Manager** | Oversees operational modules, compliance reporting, and audit logs. |
| **Ship Operator** | Registers vessels, updates ship statuses, and associates containers. |
| **Dock Manager** | Maintains dock records, availability, and dock allocations. |
| **Cargo Handler** | Manages cargo inventory and records loading, unloading, and transfer activities. |

Access to protected operations should be enforced through server-side role-based authorization.

## 🗄️ Database Design Summary

The relational database is designed around normalized entities and foreign key relationships, with **Third Normal Form (3NF)** as the target design standard.

| Table | Purpose |
|---|---|
| `ROLE` | Defines system roles and access levels. |
| `USER` | Stores user account information, password hashes, and role assignments. |
| `SHIP` | Maintains vessel details, schedules, operators, and current statuses. |
| `DOCK` | Stores dock identifiers, availability, and operational status. |
| `DOCK_ALLOCATION` | Links ships to docks and records allocation time windows. |
| `CONTAINER` | Stores container details, classifications, and vessel associations. |
| `CARGO` | Maintains cargo inventory and container relationships. |
| `CARGO_MOVEMENT` | Records chronological cargo handling events. |
| `SECURITY_LOG` | Maintains user session and security activity records. |

**Data integrity:** Foreign key constraints and appropriate validation should be used to maintain consistent relationships between records.

## 🛠️ Technology Stack and Standards

### Technology Stack

- **Frontend:** HTML5, CSS3, JavaScript, Bootstrap 5
- **Backend Architecture:** Model-View-Controller (MVC), with API separation where applicable
- **Database:** MySQL, PostgreSQL, or another compatible relational database
- **Development Tools:** Configure according to the project's actual development environment

> Update this section to match the technologies and tools implemented in the current version of the project.

### Design and Security References

- **IEEE Std 830-1998:** Software Requirements Specification (SRS) guidance
- **ISO/IEC 25010:2011:** Software product quality models
- **OWASP:** Web application security guidance

These references serve as design and development guidelines; their inclusion does not imply formal certification or compliance.

## 🔒 Non-Functional Requirements

The following are target requirements for the system, not verified production measurements.

### Security
- HTTPS/TLS protection for network communication.
- Secure password hashing using an appropriate algorithm such as bcrypt or Argon2.
- Configurable idle session timeout, with a target of 30 minutes.
- Server-side role-based access control.
- Secure handling of application secrets and database credentials.

### Performance
- Target page load time of less than 2 seconds under defined test conditions.
- Target support for 50 or more concurrent users.
- Target indexed query response time below 500 milliseconds for selected operations.

### Reliability
- Target availability of 99.5% during operational hours.
- Daily database backups with a target retention period of 30 days.
- Recovery procedures to support data restoration and operational continuity.

## 🚀 Getting Started

### Prerequisites

Before running the application, ensure you have:

- Git installed.
- The runtime, SDK, or application server required by the backend.
- A supported relational database, if required.
- The dependencies and development tools required by the project.

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/addy5786/PortErp.git
cd PortErp/Port_ERP
```

**2. Open the project**

Import or open the project in the development environment appropriate for its framework.

**3. Configure the database**

- Create the required database.
- Execute the SQL schema and setup scripts provided by the project.
- Configure the database connection settings.

**4. Configure application settings**

Set the required environment variables or configuration properties, including database connection details and application secrets.

Never commit passwords, API keys, or other sensitive credentials to GitHub.

**5. Install dependencies and run the application**

Follow the build and startup instructions for the actual backend framework and frontend setup used by this project.

> Note: Exact database setup, dependency installation, and run commands depend on the implementation and the files included in the repository.

## 🔮 Future Roadmap (v2.0)

Potential improvements for future versions include:

- Automated manifest generation and customs declaration PDF exports.
- Email and SMS notifications for dock availability and vessel alerts.
- Multi-facility support for managing multiple port locations.
- Advanced analytics and historical operational trend visualization.
- A mobile companion application for field-based cargo handlers.

## 👨‍💻 Author

**Adil Shaikh**

- GitHub: [@addy5786](https://github.com/addy5786)
- Project Repository: [PortErp](https://github.com/addy5786/PortErp)

## 📄 License

A license has not yet been specified. Add a suitable `LICENSE` file before distributing the project for reuse or modification.

---

**Port Management ERP System v1.0**

*Digitizing and streamlining maritime logistics through centralized operational management.*
