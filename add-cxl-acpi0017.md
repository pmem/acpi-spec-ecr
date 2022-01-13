# Title: Add CXL Root Object _HID

# Status: Draft

# Document: ACPI Specification 6.4

# License
SPDX-License Identifier: CC-BY-4.0

# Submitter:
* Sponsor: Vishal Verma, Intel
* Creators/Contributors:
    * Chet Douglas, Intel
    * Ben Widawsky, Intel
    * Dan Williams, Intel
    * Vishal Verma, Intel

# Summary of the Change
Add “Compute Express Link Root Object” enumeration value to the ACPI Device IDs Table (5.160).

# Benefits of the Change
Compute Express Link (CXL) is a new high-speed CPU-to-Device and CPU-to-
Memory interconnect. The new ACPI Device ID represents a singleton
device that allows the OSPM to trigger the enumeration of the CXL.mem
address space, and indicates the presence of cross Host Bridge
(ACPI0016) interleaved CXL.mem resources.

# Impact of the Change
One new row added to the ACPI Device IDs table (5.160).

# References
* Compute Express Link Specification v2.0,
<https://www.computeexpresslink.org/>

# Detailed Description of the Change

Add “Compute Express Link Root Object” enumeration device

### 5.6.7 Device Class-Specific Objects

Most device objects are controlled through generic objects and  ...

Table 5.160 ACPI Device IDs

| Value | Description                  |
| :---  | :--------------------------- |
| ..    | ..                           |
| ACPI0017 | **Compute Express Link Root Object:** This device represents the root of a CXL capable device hierarchy. It shall be present whenever the platform allows OSPM to dynamically assign CXL endpoints to a platform address space. |

## Special Instructions