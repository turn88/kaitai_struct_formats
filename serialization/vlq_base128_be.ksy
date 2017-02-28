meta:
  id: vlq_base128_be
  title: Variable length quantity, unsigned integer, base128, big-endian
doc: |
  A variable-length unsigned integer using base128 encoding. 1-byte groups
  consists of 1-bit flag of continuation and 7-bit value, and are ordered
  "most significant group first", i.e. in "big-endian" manner.

  This particular encoding is specified and used in:

  * Standard MIDI file format
  * ASN.1 BER encoding

  More information on this encoding is available at
  https://en.wikipedia.org/wiki/Variable-length_quantity

  This particular implementation supports serialized values to up 8 bytes long.
seq:
  - id: groups
    type: group
    repeat: until
    repeat-until: not _.has_next
types:
  group:
    doc: |
      One byte group, clearly divided into 7-bit "value" and 1-bit "has continuation
      in the next byte" flag.
    seq:
      - id: b
        type: u1
    instances:
      has_next:
        value: (b & 0b1000_0000) != 0
        doc: If true, then we have more bytes to read
      value:
        value: b & 0b0111_1111
        doc: The 7-bit (base128) numeric value of this group
instances:
  last:
    value: groups.size - 1
  value:
    value: >-
      groups[last].value
      + (last >= 1 ? (groups[last - 1].value << 7) : 0)
      + (last >= 2 ? (groups[last - 2].value << 14) : 0)
      + (last >= 3 ? (groups[last - 3].value << 21) : 0)
      + (last >= 4 ? (groups[last - 4].value << 28) : 0)
      + (last >= 5 ? (groups[last - 5].value << 35) : 0)
      + (last >= 6 ? (groups[last - 6].value << 42) : 0)
      + (last >= 7 ? (groups[last - 7].value << 49) : 0)
    doc: Resulting value as normal integer