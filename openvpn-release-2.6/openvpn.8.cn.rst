=========
 openvpn
=========
-------------------------
 Secure IP tunnel daemon
-------------------------

:Manual section: 8
:Manual group: 系统管理员手册



概要
========
| ``openvpn`` [ options ... ]
| ``openvpn``  ``--help``



INTRODUCTION
============

OpenVPN 是 James Yonan 开发的开源 VPN 守护进程。
因为 OpenVPN 专注于成为一个通用的 VPN 工具, 提供了很大的灵活性, 在这个手册上有很多配置选项。
如果您是 openvpn 的新手，您可能希望直接跳到示例部分，在那里您将看到如何基于命令行构建简单的 vpn ，甚至不需要配置文件。

还要注意， OpenVPN web 站点上有更多的文档和示例: https://openvpn.net/

如果你想看本手册的简短版本，请参阅 openvpn 使用信息，该信息可以通过运行 **openvpn** 获得，不带任何参数。



描述
===========

OpenVPN 是一个健壮且高度灵活的 VPN 守护程序。OpenVPN 支持 ssl /TLS 安全，
以太网桥接， 通过代理或 NAT 传输 TCP 或 UDP 隧道， 支持动态 IP 地址和 DHCP ，可扩展到数百或数千个用户，并可移植到大多数主要的操作系统平台。

OpenVPN 与 OpenSSL 库紧密绑定，并从中获得许多加密功能。

OpenVPN 支持使用预共享密钥 **(Static Key mode)** 或使用客户端和服务器证书的公钥安全 **(SSL/TLS mode)** 的传统加密。
OpenVPN 还支持非加密的 tcp /UDP 隧道。

OpenVPN 设计上就是用与大多数平台上存在的 TUN/TAP 虚拟网络接口一起工作。

总的来说， OpenVPN 旨在提供 IPSec 的许多关键特性，但占用空间相对较小


OPTIONS
=======

OpenVPN 允许在命令行或配置文件中放置任何选项。虽然所有命令行选项前面都有双破折号("--")，但是当一个选项被放置在配置文件中时，这个前缀可以被删除。

.. include:: man-sections/generic-options.cn.rst
.. include:: man-sections/log-options.rst
.. include:: man-sections/protocol-options.rst
.. include:: man-sections/client-options.rst
.. include:: man-sections/server-options.rst
.. include:: man-sections/encryption-options.rst
.. include:: man-sections/cipher-negotiation.rst
.. include:: man-sections/network-config.rst
.. include:: man-sections/script-options.rst
.. include:: man-sections/management-options.rst
.. include:: man-sections/plugin-options.rst
.. include:: man-sections/windows-options.rst
.. include:: man-sections/advanced-options.rst
.. include:: man-sections/unsupported-options.rst
.. include:: man-sections/connection-profiles.rst
.. include:: man-sections/inline-files.rst
.. include:: man-sections/signals.rst


常见问题
===

https://community.openvpn.net/openvpn/wiki/FAQ



入门知识
=====
The manual ``openvpn-examples``\(5) gives some examples, especially for
small setups.

For a more comprehensive guide to setting up OpenVPN in a production
setting, see the OpenVPN HOWTO at
https://openvpn.net/community-resources/how-to/



协议
========

An ongoing effort to document the OpenVPN protocol can be found under
https://github.com/openvpn/openvpn-rfc


官网
===

OpenVPN's web site is at https://community.openvpn.net/

Go here to download the latest version of OpenVPN, subscribe to the
mailing lists, read the mailing list archives, or browse the Git
repository.



BUGS
====

Report all bugs to the OpenVPN team info@openvpn.net



SEE ALSO
========

``openvpn-examples``\(5),
``dhcpcd``\(8),
``ifconfig``\(8),
``openssl``\(1),
``route``\(8),
``scp``\(1)
``ssh``\(1)



注意
=====

This product includes software developed by the OpenSSL Project
(https://www.openssl.org/)

For more information on the TLS protocol, see
http://www.ietf.org/rfc/rfc2246.txt

For more information on the LZO real-time compression library see
https://www.oberhumer.com/opensource/lzo/



版权
=========

Copyright (C) 2002-2020 OpenVPN Inc This program is free software; you
can redistribute it and/or modify it under the terms of the GNU General
Public License version 2 as published by the Free Software Foundation.

AUTHORS
=======

James Yonan james@openvpn.net
