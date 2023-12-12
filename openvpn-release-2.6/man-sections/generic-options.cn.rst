通用配置
---------------
本节涵盖了可访问的通用选项，无论 OpenVPN 配置为哪种模式。

--help

  查看配置.

--auth-nocache
  不要在虚拟内存中缓存 ``--askpass`` 或 ``--auth-user-pass`` 用户名/密码。
  如果指定了该指令， OpenVPN 就会在使用用户名/密码输入后立即将其遗忘。因此，当 OpenVPN 需要用户名/密码时，它会提示从 stdin 输入，这在 OpenVPN 会话期间可能会出现多次。
  在结合用户名/密码文件和 ``--chroot`` 或 ``--daemon`` 使用 ``--auth-nocache`` 时，请确保使用绝对路径。

  该指令不影响 ``--http-proxy`` 用户名/密码。它始终处于缓存状态。

--cd dir
  在读取任何文件（如配置文件、密钥文件、脚本等）之前，将目录更改为 ``dir``.
  配置文件、密钥文件、脚本等。dir 应为绝对路径，以 `/` 开头，且不包含对目录的任何引用。
  应为绝对路径，以 `/` 开头，且不包含对当前目录的任何引用，如
  当前目录的引用，如 :code:`.` 或 :code:`..`。

  该选项在以 `--daemon ` 模式运行 OpenVPN 时非常有用、
  并希望将所有 OpenVPN 控制文件合并到一个位置时，该选项非常有用。

--chroot dir
  初始化后 Chroot 到 ``dir``. ``--chroot`` 本质上是将 ``dir`` 重新定义为顶级目录树 (/)。
  因此， OpenVPN 因此将无法访问此目录树之外的任何文件。
  从安全角度来看是可取的。

  由于 chroot 操作会延迟到初始化之后进行，因此大多数引用文件的 OpenVPN 选项将在 chroot 前的上下文中运行。

  在许多情况下，``dir`` 参数可以指向一个空目录、
  但是，在 chroot 操作之后执行脚本或重启时，可能会导致复杂问题。
  chroot 操作后执行脚本或重启时，可能会出现问题。

  注意： SSL 库可能需要/dev/urandom 在 chroot 目录 ``dir`` 内。
  这是因为 SSL 库偶尔需要收集新的随机性。较新的 Linux 内核和一些
  BSD 实现了 getrandom() 或 getentropy() 系统调用，从而消除了对 /dev/urandom 的需求。

--compat-mode version
  该选项提供了一种方便的方法来更改 OpenVPN 的默认设置，使其与指定的版本 ``version`` 更加兼容。

  该选项指定的版本是 OpenVPN 对等网络的版本。
  一般来说， OpenVPN 应与前两个版本兼容。例如
  OpenVPN 2.6.0 应与 2.5.x 和 2.4.x 兼容，而无需此选项。
  不过，在某些边缘情况下，仍可能需要此选项。

  注意：使用该选项会将默认值还原为不再推荐的值，因此应尽可能避免使用。
  值，因此应尽可能避免使用。

  下表详细说明了根据指定的版本不同，默认值会有哪些变化。

  - 2.5.x or lower: ``--allow-compression asym`` is automatically added
    to the configuration if no other compression options are present.
  - 2.4.x or lower: The cipher in ``--cipher`` is appended to
    ``--data-ciphers``.
  - 2.3.x or lower: ``--data-cipher-fallback`` is automatically added with
    the same cipher as ``--cipher``.
  - 2.3.6 or lower: ``--tls-version-min 1.0`` is added to the configuration
    when ``--tls-version-min`` is not explicitly set.

  如果不需要，应避免使用该选项。设置该选项可能会降低安全性或禁用数据通道卸载等功能。

--config file
  从 ``file`` 中加载附加配置选项，每行对应一个命令行选项，但去掉前导
  对应一个命令行选项，但去掉了前导 :code: `--` 。

  如果 ``--config file`` 是 openvpn 命令的唯一选项，则可删除配置文件.

  请注意，配置文件可以嵌套到合理的深度。
  双引号或单引号字符（""、''）可用于
  双引号或单引号字符（""、''）括起包含空白的单个参数，第一列中的 "#" 或 ";" 字符可用于表示注释。

  请注意， OpenVPN 2.0 及更高版本会对不在单引号内的字符执行基于反斜杠的外壳转义处理。
  对不在单引号内的字符执行基于反斜杠的外壳转义，因此应遵守以下映射规则
  应遵守：
  ::

      \\       Maps to a single backslash character (\).
      \"       Pass a literal doublequote character ("), don't
               interpret it as enclosing a parameter.
      \[SPACE] Pass a literal space or tab character, don't
               interpret it as a parameter delimiter.

  例如，在 Windows 系统中，使用双反斜线表示路径名：
  ::

      secret "c:\\OpenVPN\\secret.key"


  For examples of configuration files, see
  https://openvpn.net/community-resources/how-to/

  下面是一个配置文件示例:
  ::

      #
      # Sample OpenVPN configuration file for
      # using a pre-shared static key.
      #
      # '#' or ';' may be used to delimit comments.

      # Use a dynamic tun device.
      dev tun

      # Our remote peer
      remote mypeer.mydomain

      # 10.1.0.1 is our local VPN endpoint
      # 10.1.0.2 is our remote VPN endpoint
      ifconfig 10.1.0.1 10.1.0.2

      # Our pre-shared static key
      secret static.key

--daemon progname
  完成所有初始化功能后成为守护进程。

  有效语法：：

  守护进程
  守护进程名称

  Valid syntaxes::

    daemon
    daemon progname

  该选项将导致所有信息和错误输出发送到 syslog 文件（如 :code:`/var/log/messages`），但脚本和 ifconfig 命令的输出除外。
  syslog 重定向会在 ``--daemon `` 在命令行中被解析时，系统日志重定向会立即发生，
  即使守护进程的时间点在后。如果存在 ``--log`` 选项，它将取代 syslog 重定向。

  可选的 ``progname`` 参数将导致 OpenVPN 向系统日志报告。
  这在将 syslog 文件中的 OpenVPN 消息与特定隧道联系起来。
  当未指定时， progname 默认为 :code:`openvpn`。

  当使用 ``--daemon`` 选项运行 OpenVPN 时，
  它会尽量延迟守护进程，直到大部分会产生致命错误的初始化函数都已完成。
  这意味着初始化脚本可以通过测试 openvpn 命令的返回状态，
  以相当可靠地判断该命令是否已正确初始化并进入数据包转发程序。

  在 OpenVPN 中，初始化后发生的绝大多数错误都是非致命性的错误。

  注意：一旦 OpenVPN 进入守护进程，就不能再询问用户名、密码或关键密码短语、
  这将产生某些后果,即使用受密码保护的私钥会失败，
  除非使用 ``--askpass`` 选项来告诉 OpenVPN 询问密码短语，否则使用受密码保护的私钥就会失败。
  (这一要求是 v2.3.7 中的新规定，是在初始化之前调用
  daemon() 的结果）。

  此外，使用 ``--daemon`` 和 ``--auth-user-pass`` （在控制台输入
  用户密码（在控制台输入）和 ``--auth-nocache`` 会在密钥重新协商（和重新验证）就会失败。

--disable-dco
  禁用 "数据通道卸载" `DCO` 。

  在 Linux 上，不要使用 ovpn-dco 设备驱动程序，而应依赖 legacy tun 模块。

  如果你的服务器需要允许旧版本的客户端连接。

--disable-occ
  **DEPRECATED** 
  **已删除** 在不使用 TLS 的配置中禁用 `选项一致性检查` (OCC)。

  如果检测到对等程序之间的选项不一致，则不输出警告信息。
  选项不一致时，不输出警告信息。选项不一致的一个例子是一个
  对等点使用 ``--dev tun``，而另一个对等点使用 ``--dev tap``。

  不鼓励使用该选项，但在以下情况下可作为临时解决方案使用
  新版本的 OpenVPN 必须连接到旧版本的情况。
  版本。

--engine engine-name
  启用 OpenSSL 基于硬件的加密引擎功能。

  有效语法：：

  引擎
  引擎名称

  如果指定了 ``engine-name`` ，则使用特定的加密引擎。使用
  独立选项来列出 OpenSSL 支持的加密引擎。
  支持的加密引擎。

--fast-io
  (实验特性）
  通过避免在写入操作前调用 poll/epoll/select ，优化 TUN/TAP/UDP I/O 写入。
  这种调用的目的调用的目的通常是阻塞，直到设备或套接字准备好接受写入。
  在某些平台上，这种阻塞是不必要的。因为这些平台不支持 UDP 套接字或 TUN/TAP 设备上的写阻塞。
  在这种情况下，可以通过避免调用 poll/epoll/select 来优化事件循环，将 CPU 效率提高 5%-10%。
  该选项只能用于非 Windows 系统，当指定了 ``--proto udp `` 且未指定 ``--shaper`` 时，才能在非 Windows 系统上使用此选项。

--group group
  与 ``--user`` 选项类似，该选项会在初始化后将 OpenVPN 进程的组 ID 更改为 ``group`` 。
  初始化后将 OpenVPN 进程的组 ID 更改为 ``group``。

--ignore-unknown-option args
  Valid syntax:
  ::

     ignore-unknown-options opt1 opt2 opt3 ... optN

  当配置文件中出现选项 ``opt1 ... optN`` 时
  如果该 OpenVPN 版本不支持该选项，则配置文件解析不会失败。
  不支持该选项时，配置文件解析不会失败。多个 ``--ignore-unknown-option`` 选项
  以支持更多的忽略选项。

  使用该选项时应谨慎，因为有充分的安全理由说明, 因为如果 OpenVPN 检测到配置文件有问题，它就会失效，这是很好的安全理由。
  不过，也有合理的理由希望新的软件, 功能在遇到旧版本软件时优雅地降级也是有道理的。
  旧版本的软件时，希望新软件功能能够优雅地降级也是有道理的。

  ``--ignore-unknown-option`` is available since OpenVPN 2.3.3.

--iproute cmd
  设置替代默认 ``iproute2`` 命令的执行命令。
  可用于在非特权环境下执行 OpenVPN。

--keying-material-exporter args
  保存导出的秘钥 [RFC5705] of ``len`` bytes (must be between 16
  and 4095 bytes) using ``label`` in environment
  (:code:`exported_keying_material`) for use by plugins in
  :code:`OPENVPN_PLUGIN_TLS_FINAL` callback.

  Valid syntax:
  ::

    keying-material-exporter label len

  Note that exporter ``labels`` have the potential to collide with existing
  PRF labels. In order to prevent this, labels *MUST* begin with
  :code:`EXPORTER`.

--mlock
  通过调用 POSIX mlockall 函数禁用分页。要求 OpenVPN 最初以根用户身份运行（尽管 OpenVPN 可以随后使用UID ）。

  使用该选项可确保密钥材料和隧道数据不会因写入磁盘的虚拟内存分页操作写入磁盘。
  这样即使攻击者能破解运行 OpenVPN 的盒子，他也无法扫描系统交换文件来恢复以前使用过的
  系统交换文件来恢复以前使用过的短暂密钥。
  短暂密钥的使用时间由 ``--reneg`` 选项（见下文选项的规定使用一段时间，然后丢弃。）

  使用 ``--mlock`` 的缺点是会减少其他应用程序可用的物理内存量。
  可锁定内存的限制以及该限制的执行方式取决于操作系统。
  在 Linux 上，一个无权限进程可锁定内存的默认限制（ RLIMIT_MEMLOCK ）很低，
  如果以后取消了权限，那么未来的内存分配将非常困难。
  权限被取消，未来的内存分配很可能会失败。
  可以使用 ulimit 或 systemd 指令来增加限制，具体取决于 OpenVPN 的启动方式。

  如果平台有 getrlimit(2) 系统调用， OpenVPN 将在调用 mlock 之前检查
  在调用 mlockall(2) 之前， OpenVPN 会检查 mlock 可用内存的数量，并
  如果配置的内存小于 100 MB ，则会尝试将限制增加到 100 MB。
  对于一个中等规模的 100 MB 在某种程度上是任意设定的,
  但如果并发客户端数量较多，内存使用量可能会超过这一限制。
  但如果并发客户端数量较多，内存使用量可能会超过这一上限。

--nice n
  初始化后更改进程优先级 (``n`` greater than 0 is
  lower priority, ``n`` less than zero is higher priority).

--persist-key
  不要重复读取 key files across :code:`SIGUSR1` or ``--ping-restart``.

  该选项可与 ``--user`` 结合使用，以允许由 :code:`SIGUSR1` 信号触发的重启。
  由 :code:`SIGUSR1` 信号触发。通常情况下，如果在 OpenVPN 中放弃 root
  权限，守护进程将无法重启，因为它现在无法重新读取受保护的密钥文件。

  该选项通过在 :code:`SIGUSR1` 重置时持续保存密钥来解决这个问题。
  重置时也能持久保存密钥，因此无需重新读取。

--providers providers
  加载（ OpenSSL ）提供程序列表。这主要用于使用外部提供程序进行密钥管理, 比如 tpm2-openssl, 
  或通过指定如下参数加载带有传统提供程序

  ::

      --providers legacy default

  Behaviour of changing this option between :code:`SIGHUP` might not be well behaving.
  If you need to change/add/remove this option, fully restart OpenVPN.

--remap-usr1 signal
  控制信号是内部生成还是外部生成 :code:`SIGUSR1` signals
  are remapped to :code:`SIGHUP` (restart without persisting state) or
  :code:`SIGTERM` (exit).

  ``signal`` can be set to :code:`SIGHUP` or :code:`SIGTERM`. By default,
  no remapping occurs.

--script-security level
  该指令对 OpenVPN 使用外部程序和脚本进行策略级控制。
  外部程序和脚本的使用。较低的级别值更具限制性，较高的级别值更具许可性。
  限制性更强，数值越大则越宽松。 
  Settings for ``level``:

  :code:`0`
      Strictly no calling of external programs.

  :code:`1`
      (Default) Only call built-in executables such as ifconfig,
      ip, route, or netsh.

  :code:`2`
      Allow calling of built-in executables and user-defined
      scripts.

  :code:`3`
      Allow passwords to be passed to scripts via environmental
      variables (potentially unsafe).

  OpenVPN releases before v2.3 also supported a ``method`` flag which
  indicated how OpenVPN should call external commands and scripts. This
  could be either :code:`execve` or :code:`system`. As of OpenVPN 2.3, this
  flag is no longer accepted. In most \*nix environments the execve()
  approach has been used without any issues.

  Some directives such as ``--up`` allow options to be passed to the
  external script. In these cases make sure the script name does not
  contain any spaces or the configuration parser will choke because it
  can't determine where the script name ends and script options start.

  To run scripts in Windows in earlier OpenVPN versions you needed to
  either add a full path to the script interpreter which can parse the
  script or use the ``system`` flag to run these scripts. As of OpenVPN
  2.3 it is now a strict requirement to have full path to the script
  interpreter when running non-executables files. This is not needed for
  executable files, such as .exe, .com, .bat or .cmd files. For example,
  if you have a Visual Basic script, you must use this syntax now:

  ::

     --up 'C:\\Windows\\System32\\wscript.exe C:\\Program\ Files\\OpenVPN\\config\\my-up-script.vbs'

  Please note the single quote marks and the escaping of the backslashes
  (\\) and the space character.

  The reason the support for the :code:`system` flag was removed is due to
  the security implications with shell expansions when executing scripts
  via the :code:`system()` call.

--setcon context
  初始化后应用 SELinux ``context``. 
  这基本上提供了将 OpenVPN 的权限限制为只能进行网络 I/O操作。
  这比 ``--user`` 和 ``--chroot`` 更进一步。
  但不幸的是，它们并不能防止特权升级。
  当然，你可以将这三种结合使用
  但请注意，由于 setcon 需要访问 /proc ，因此你必须在 chroot 中提供访问 /proc 的权限。
  必须在 chroot 目录中提供（例如使用 mount-绑定）。

  由于 setcon 操作会延迟到初始化之后进行、OpenVPN 只能调用与网络相关的系统调用，
  而在启动前应用上下文（如在 SELinux 参考策略中提供的 OpenVPN 上下文），
  你将不得不允许许多限制只有在初始化时才需要。

  与 chroot 一样，在 setcon 操作后执行脚本或重启时也会导致复杂问题。
  在 setcon 操作后执行脚本或重启时，就会出现问题。
  考虑使用 ``--persist-key`` 和 ``--persist-tun`` 选项。

--status args
  用于配置周期性更新操作状态到文件的频率

  Write operational status to ``file`` every ``n`` seconds. ``n`` defaults
  to :code:`60` if not specified.

  Valid syntaxes:
  ::

    status file
    status file n

  Status can also be written to the syslog by sending a :code:`SIGUSR2`
  signal.

  With multi-client capability enabled on a server, the status file
  includes a list of clients and a routing table. The output format can be
  controlled by the ``--status-version`` option in that case.

  For clients or instances running in point-to-point mode, it will contain
  the traffic statistics.

--status-version n
  指定状态文件的格式（版本号）
  Set the status file format version number to ``n``.

  This only affects the status file on servers with multi-client
  capability enabled.  Valid status version values:

  :code:`1`
      Traditional format (default). The client list contains the
      following fields comma-separated: Common Name, Real Address, Bytes
      Received, Bytes Sent, Connected Since.

  :code:`2`
      A more reliable format for external processing. Compared to
      version :code:`1`, the client list contains some additional fields:
      Virtual Address, Virtual IPv6 Address, Username, Client ID, Peer ID,
      Data Channel Cipher. Future versions may extend the number of fields.

  :code:`3`
      Identical to :code:`2`, but fields are tab-separated.

--test-crypto
  使用上述数据通道加密选项加密和解密测试数据包，对 OpenVPN 的加密选项进行自我测试数据包。
  该选项无需对等设备即可运行，因此无需指定 ``--dev`` or ``--remote``.

  The typical usage of ``--test-crypto`` would be something like this:
  ::

     openvpn --test-crypto --secret key

  or

  ::

     openvpn --test-crypto --secret key --verb 9

  该选项非常有用，可在 OpenVPN 移植到新平台后对其进行测试，
  或隔离编译器、OpenSSL 加密OpenSSL 加密库或 OpenVPN 加密代码中的问题。
  由于这是一种自测试模式，加密和身份验证问题可以独立于网络和隧道问题进行调试。

--tmp-dir dir
  为临时文件指定一个目录 ``dir``。此目录将进程和脚本使用，以便与openvpn 主进程传递临时数据。
  请注意，该目录必须可由 OpenVPN 进程取消 root 权限后可写入该目录。

  在以下情况下将使用该目录:

  * ``--client-connect`` scripts and :code:`OPENVPN_PLUGIN_CLIENT_CONNECT`
    plug-in hook to dynamically generate client-specific configuration
    :code:`client_connect_config_file` and return success/failure via
    :code:`client_connect_deferred_file` when using deferred client connect
    method

  * :code:`OPENVPN_PLUGIN_AUTH_USER_PASS_VERIFY` plug-in hooks returns
    success/failure via :code:`auth_control_file` when using deferred auth
    method and pending authentication via :code:`pending_auth_file`.

--use-prediction-resistance
  在 mbed TLS 的 RNG 上启用抗预测功能。
  启用抗预测功能会导致 RNG 在每次调用随机。如此频繁的重新编排会迅速耗尽内核熵池。
  如果需要此选项，请考虑运行一个向内核熵池添加熵的守护进程。

--user user
  初始化后，将 OpenVPN 进程的用户 ID 更改为 ``user``.
  初始化后将 OpenVPN 进程的用户 ID 更改为 ``user``，从而降低进程的权限。
  该选项可在某些敌对方控制 OpenVPN 会话时保护系统。
  虽然 OpenVPN 的安全特性使这种情况不太可能发生，但它仍可作为第二道防线。

  通过将 ``user`` 设置为专门运行 openvpn 的非特权用户、
  敌方可能造成的破坏就会受到限制。
  当然，一旦剥夺了权限，就无法将其返回到 OpenVPN 会话。
  举例来说，这意味着如果要重置一个代码： `SIGUSR1` 信号重置 OpenVPN 守护进程（例如响应DHCP 重置），
  就应该使用一个或多个 ``--persist`` 选项，
  以确保 OpenVPN 不需要执行任何特权操作（如重新读取密钥文件或运行 ``ifconfig`` ）。

  注意：以前版本的 openvpn 使用 :code:`nobody` 作为无特权用户的示例。
  无特权用户。不建议实际使用该用户因为它通常已被其他系统服务使用。
  请始终为 openvpn 创建专用用户。

--writepid file
  将 OpenVPN 的主进程 ID 写入文件 ``file``.
