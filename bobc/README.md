bobc
=====

A Cowboy OTP application

Build
-----

`rebar3 compile`

Start
-----

`start.bat Name InternalPort ExternalPort RemotePort`

Where:
- **InternalPort** - main cowboy port, port were you enstablish connection with your desktop client
- **ExternalPort** - port that you listen for incoming connections
- **RemotePort** - port of second node that you try to connect (*debug feature*)