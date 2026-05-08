Fosters report
-----------------

This report lists the foster parents and their preferred pet type.

%{ for foster, pet in fosters ~}
- **${foster}** prefers **${pet}**
%{ endfor ~}
