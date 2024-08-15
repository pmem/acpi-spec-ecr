# Title: "Extended-linear" addressing for direct-mapped memory-side caches

# Status: v5

# Document: ACPI Specification 6.6

# License
SPDX-License Identifier: CC-BY-4.0

# Submitter:
* Sponsor: Dan Williams, Intel
* Creators/Contributors:
    * Andy Rudoff, retired
    * Mahesh Natu, Intel
    * Ishwar Agarwal, Intel

# Changelog
* v5: Move implemetation note per ASWG feedback
* v4: Drop "improved cache utilization" claim (Jonathan)
* v4: Clarify SPA vs HPA terminology
* v4: Clarify possibility and difficulty of multiple CPER records to
  communicate aliases (Jonathan)
* v4: Clarify that N is expected to be an integer ration of "near" to
  "far" memory. (Jonathan)
* v3: Replace "Inclusive Linear" with "Extended-linear" term, and
  clarify the SPA vs HPA behavior of this cache addressing mode.
  (Jonathan)
* v2: Clarify the "Inclusive" term as "including the capacity of the cache
  in the SRAT range length"
* v2: Clarify that 0 is an undeclared / transparent Address Mode, and
  that Address Mode values other than 1 are Reserved.

v3: http://lore.kernel.org/6650e4f835a0e_195e294a8@dwillia2-mobl3.amr.corp.intel.com.notmuch
v2: http://lore.kernel.org/663ea70884cfd_db82d29414@dwillia2-xfh.jf.intel.com.notmuch

# Summary of the Change
Recall that one of the modes available with persistent memory (PMEM) was a
direct-mapped memory-side cache where DDR-memory transparently cached
PMEM. This article has more details:

https://thessdguy.com/intels-optane-two-confusing-modes-part-2-memory-mode/

...but the main takeaway of that article that is relevant for this ECN
is:

    "[PMEM] is paired with a DRAM that behaves as a cache, and,
     like a cache, it is invisible to the user. [..] A typical system
     might combine a 64GB DRAM DIMM with a 512GB Optane DIMM, but the
     total memory size will appear to the software as only 512GB."

Instead, this new "extended-linear" direct-mapped memory-side cache
addressing mode would make the memory-size that appears to software in
the above example as 576GB, an increase of addressable capacity.

A primary motivation for updating HMAT to explicitly enumerate this
addressing mode is due to the OSPM's increased role for RAS and
address-translation with CXL topologies. With CXL and OS native RAS
flows OSPM is responsible for understanding and navigating the
relationship between System-Physical-Address (SPA) ranges published
ACPI.SRAT.MemoryAffinity, Host-Physical-Address ranges (HPA) published
in the ACPI.CEDT.CFMWS, and HPAs programmed in CXL memory expander
endpoints.

Enable an OSPM to enumerate that the capacity for a memory-side cache
extends an SRAT range. Typically the "Memory Side Cache Size" enumerated
in the HMAT is "excluded" from the SRAT range length because it is a
transparent cache of the SRAT capacity. I.e. typical systems present 1:1
SPA:HPA, extended-linear memory-side-cache systems alias multiple SPAs
to a single CXL HPA.  The enumeration of this addressing mode enables
OSPM-memory-RAS (Reliability, Availability, and Serviceability) flows.

# Benefits of the Change
Without this change an OSPM that encounters a memory-side cache
configuration of DDR fronting CXL may not understand that an SRAT range
extended by cache capacity should be maintained as one contiguous SPA
range even though the CXL HPA decode configuration only maps a subset of
the SRAT SPA range. In other words the memory-side-cache dynamically
maps access to that SPA range to either a CXL or DDR HPA.

Without this change the only way for system software to become aware of
the fact that one memory poison event implicates multiple address
locations would be for multiple error records (CPER) to be emitted
per-poison consumption event. That may surprise existing OSPM
implementations.

With this change, the OSPM can enumerate aliases and take actions like
quarantine / offline all the impacted aliased pages to prevent further
consumption of poison, or run repair operations on all the affected
targets. The OSPM is enabled to identify the HPA associated with a given
CXL endpoint DPA event, and understand how SPAs map to CXL HPAs.

# Impact of the Change
The proposed "Address Mode" field consumes the 2 Reserved bytes
following the "Cache Attributes" field in the "Memory Side Cache
Information Structure". The default reserved value of 0 indicates the
status quo of an undeclared addressing mode where the expectation is
that it is safe to assume the cache-capacity is transparent to the SRAT
range capacity. An OSPM that knows about new values can consider SPA to
HPA relationships according to the address-layout definition proposed
below. A legacy OSPM will ignore it as a Reserved field.

# References
* Compute Express Link Specification v3.1,
<https://www.computeexpresslink.org/>

# Detailed Description of the Change

* Section Table 5.149: Memory Side Cache Information Structure redefine
  the 2 Reserved bytes starting at offset 28 as "Address Mode":

    * 0 - Reserved (Unknown Address Mode)
    * 1 - Extended-linear (N direct-map aliases linearly mapped)
    * 2..65535 - Reserved (Unknown Address Mode)

* Include in that "Address Mode" description an "Implementation note" that reads:

    "Implementation note: When Address Mode is 1 'Extended-Linear' it
     indicates that the associated address range
     (SRAT.MemoryAffinityStructure.Length) is comprised of the backing
     store capacity extended by the cache capacity. It is arranged such
     that there are N directly addressable aliases of a given cacheline
     where N is an integer ratio of target memory proximity domain size
     and the memory side cache size. Where the N aliased addresses for a
     given cacheline all share the same result for the operation
     'address modulo cache size'.  This setting is only allowed when
     'Cache Associativity' is 'Direct Map'."
