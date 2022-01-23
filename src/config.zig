/// Set whether or not bustd should daemonize
/// itself. Don't use this if running bustd as a systed
/// daemon or something of the sort.
pub const should_daemonize: bool = false;

/// Free RAM percentage figures below this threshold are considered to be near terminal, meaning 
/// that bustd will start to check for Pressure Stall Information whenever the
/// free RAM figures go below this.
/// However, this free RAM amount is what the sysinfo syscall gives us, which does not take in consideration
/// reclaimable or cached pages. The true free RAM amount available to the OS is bigger than what it indicates.
pub const free_ram_threshold: u8 = 15;

/// The Linux kernel presents canonical pressure metrics for memory, found in `/proc/pressure/memory`.
/// Example:
///    some avg10=0.00 avg60=0.00 avg300=0.00 total=11220657
///    full avg10=0.00 avg60=0.00 avg300=0.00 total=10947429
/// These ratios are percentages of recent trends over ten, sixty, and 
/// three hundred second windows. The `some` row indicates the percentage of time
// in that given time frame in which _any_ process has stalled due to memory thrashing.
///
/// This value configured here is the value of `some avg10` in which, if surpassed, some 
/// process will be killed.
///
/// The ideal value for this cutoff varies a lot between systems.
/// Try messing around with `tools/mem-eater.c` to guesstimate a value that works well for you.
pub const cutoff_psi: f32 = 0.05;