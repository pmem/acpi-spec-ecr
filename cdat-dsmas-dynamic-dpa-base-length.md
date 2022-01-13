# Title: CDAT DSMAS allow runtime updates to DPA base and length

# Status: Draft v1

# Document: ACPI Specification 6.5

# License
SPDX-License Identifier: CC-BY-4.0

# Submitter:
* Sponsor: Dan Williams, Intel
* Creators/Contributors:
    * Chet Douglas, Intel

# Summary of the Change
Allow the CDAT DSMAS DPA 'Base' and 'Length' fields to be changed at runtime.

# Benefits of the Change
With CXL attached memory it is desirable to allow complete configuration and partitioning of the device without the need to reset it or reboot the system.  By allowing the CDAT DSMAS DPA Base and Length to change at runtime, the device can change these boundaries in response to changes in the device’s memory partitioning.

# Impact of the Change
The change necessitates bumping the CDAT 'revision' to '2'. For new devices supporting
this revision, additional flexibility is gained with how CDAT information can be consumed.

# References
* Compute Express Link Specification v2.0,
<https://www.computeexpresslink.org/>

# Detailed Description of the Change

* Table 1- Coherent Device Attribute Table (CDAT) Format:

  * Update the 'Revision' field to '2'
  * In the 'Sequence' field, add text as shown below (**Bold**).
  * In the 'Sequence' field, remove text as shown below (~~strikethrough~~).


| Field    | Byte Length | Byte Offset | Description                  |
| :-----   | :---        | :---        | :--------------------------- |
| ...      | ...         | ...         | ...                          |
| Revision | ~~1~~ **2** | 4           | Must be set to ~~1~~ **2** for the format defined by this specification. Any future revisions will maintain compatibility with prior revisions. Future CDAT revisions are permitted to introduce new structure types or assign meaning to Reserved fields in the CDAT header but are not permitted to redefine the meaning of previously defined fields. |
| ...      | ...         | ...         | ...                          |
| Sequence | 4           | 12          | *See formatted text below*   |

The contents of CDAT returned by a component may change
during runtime. A component shall reset the sequence number to 0
upon reset. Sequence number field shall be incremented by 1 if the
content of CDAT being returned is different from the content that
was returned last. The sequence field shall roll over after reaching
its maximum value.

For Revision=1, the following changes are permitted during the
runtime

* Changes to the latency and bandwidth fields in DSLBIS
* Changes to the latency and bandwidth fields in SSLBIS
* Changes to the number of DSEMTS instances and their contents

The changes to latency and bandwidth may represent events such
as failover or degradation that are internal to a component.
DSEMTS updates may represent memory being brought online or
taken offline.

**For Revision=2, the following changes are permitted during
runtime in addition to those changes permitted in Revision 1**

* **Changes to the DPA base and length fields in DSMAS**

**The changes to DPA base and length may represent runtime
configuration changes that affect the range of memory a DSMAS
instance applies to (e.g. CXL Set Partition Info).**

No other changes are permitted ~~if Revision=1~~. The list of not
permitted changes include, but are not limited to

* The Number of DSMAS instances ~~and their content~~
* The Number of DSLBIS instances
* The Number of DSIS instances and their content
* The Number of DSMSCIS instances
* The Number of SSLBIS instances

If CDAT is being exposed via EFI_ADAPTER_INFORMATION_PROTOCOL,
this field shall be set to 0.