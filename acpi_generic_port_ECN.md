# Title: Introduce a Generic Port for hotplug memory buses like CXL

# Status: Draft v2

# Document: ACPI Specification 6.4

# License
SPDX-License Identifier: CC-BY-4.0

# Submitter:
* Sponsor: Dan Williams, Intel
* Creators/Contributors:
    * Mahesh Natu, Intel
    * Chet Douglas, Intel
    * Deepak Shivakumar, Intel
    * Jonathan Cameron, Huawei

# Changes since v1
  * Rename Generic Target to Generic Port and make a new distinct SRAT
    type independent of Generic Initiator (Jonathan)
  * Clarify that this new "Port" concept is not limited to CXL. It is a
    generic way to describe the performance of static paths to
    dynamically added system memory (Mahesh)

# Summary of the Change
Introduce a new "Generic Port" type to the SRAT to describe the
performance from CPU and other initiator domains to the root of a CXL
topology, or any other topology that might dynamically add system memory
behind the "Port". This is in support of, but not limited to, the OS
being able to enumerate the performance topology for dynamically added /
discovered CXL Memory Device endpoints.

# Benefits of the Change
Consider the case of a system with a set of CXL Host Bridges (ACPI0016),
and some endpoints attached at boot. In that scenario the platform
firmware is able to enumerate those devices, enumerate and map CXL
memory into the system physical memory address space, and generate the
typical static SRAT/SLIT/HMAT set of tables describing CXL attached
memory. Now, consider the case where devices are dynamically added and
enumerated post boot, i.e. post generation of the static memory tables.
In this scenario platform firmware is unable to perform the end-to-end
enumeration necessary to populate SRAT and HMAT for the endpoints that
may be hot-inserted behind those bridges post power-on. The
address-range is unknown so SRAT can not be pre-populated in the typical
way that hotplug system memory is enumerated. Even if a static address
range was set aside for future hotplug the performance is unknown (no
CDAT nor interleave configuration) so HMAT can not be pre-populated.

However, what is known to platform firmware that generates the
SRAT/SLIT/HMAT and is the performance characteristics of the path
between CPU and Generic Initiators to the Generic Port (e.g. CXL Host
Bridge). With the addition of a Generic Port proximity domain to the
SRAT then the SLIT and HMAT can enumerate the platform-static component
of a given edge in the platform-performance topology graph. It enables
the OS to build out a performance mapping for system memory address
ranges dynamically discovered, or provisioned, behind a Generic Port.
The OS mapping takes into account the Generic Port performance (as
either an initiator or a target), the interleave configuration, and the
bus enumerable performance characteristics (link latency, bandwidth,
switch traversals) to supplement the static HMAT data enumerated at
boot.

# Impact of the Change
A new SRAT type requires non-conforming system software to ignore the
new type in the SRAT, ignore any coordinate in the SLIT that includes
the associated port's proximity domain, and ignore any coordinate in the
HMAT that includes the port's proximity domain as either an initiator or
a target.

In contrast, conforming system software need only consult the Generic
Port data to optionally extend the enumeration and distinguish Port
attached initiators and memory targets from the existing set of
enumerated proximity domains.

A conforming implementation also has the option to ignore the Generic Port
contribution to the performance, in either a row, or col  to be considered
by system software that parses SRAT, SLIT, and HMAT. Given that the OS
still needs to dynamically enumerate and instantiate the memory ranges and
initiators behind the Generic Port. The assumption is that operating systems
that do not support native CXL enumeration will ignore this data in the HMAT,
while CXL native enumeration aware environments will use this fragment of the
performance path to calculate the performance characteristics.

# References
* Compute Express Link Specification v2.0,
<https://www.computeexpresslink.org/>

# Detailed Description of the Change

* Section 5.2.16 System Resource Affinity Table (SRAT) add another
  bullet for Generic Ports:

	* generic ports (e.g. host bridges that can dynamically discover
	  new initiators and instantiate new memory range targets)

* Add new section 5.2.16.7 Generic Port Affinity Structure:
  The Generic Port Affinity Structure provides an association between a
  proximity domain number and a device handle representing a Generic
  Port (e.g. CXL Host Bridge, or similar device that hosts a dynamic
  topology of memory ranges and/or initiators).

  Support of Generic Port Affinity Structures by an OSPM is optional.

* Add a table describing the Generic Port Affinity Structure (Table
  5.xx):


| Field  | Byte Length | Byte Offset | Description                  |
| :----- | :---        | :---        | :--------------------------- |
| Type   | 1           | 0           | 6 Generic Port Structure     |
| Length | 1           | 1           | 32                           |
| Reserved | 1         | 2           | Reserved and must be zero    |
| Device Handle Type | 1 | 3 | Device Handle Type: See 5.2.16.6 Generic Initiator Affinity Structure for the possible device handle types and their format. |
| Proximity Domain | 4 | 4 | The proximity domain to identify the performance of this port in the HMAT. |
| Device Handle | 16   | 8           | Device Handle of the Generic Port, see Table 5.57 and 5.58 for a description of this field. |
| Flags  | 4           | 24          | See table 5.59 for a description of this field. |
| Reserved | 4         | 28          | Reserved and must be zero.   |

* Replace all instances of "Initiator" with "Initiator / Port" in "Table
  5.59 Flags - Generic Initiator Affinity Structure", including the
  table name.