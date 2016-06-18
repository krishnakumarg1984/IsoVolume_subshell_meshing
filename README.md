# IsoVolume Subshell Meshing
Code that helps to divide a sphere of radius R, into sub-shells of equal volumes, for a given thickness of outermost sub-shell. 

The mesh used in a FD/FV/FE discretisation for solid diffusion
simulation is often constructed such that the inter-nodal distance ensure that the sub-shells all have equal volumes.
This is non-trivial to derive by hand for anything other than 2 or 3 layers,  and the complexities are described with adequate dose of comments inline.

Electrochem/chemical reactions usually occur at the surface of the particle, and hence we need more mesh-points closer to the surface, and as matter moves towards the centre, we need progressively lesser points, i.e. in 1D domain, with the left representing the centre, and the right representing the surface, we need a non-uniformly spaced mesh, such that the corresponding spheres represented by the inter-nodal distance have equal volume.

As an end-user, you input the sphere radius, and the inter-nodal distance at the surface, (i.e. the smallest mesh-size) and the code generates all the mesh co-ordinates for you, as well as the inter-nodal distances (just in case you wish to use them in your calculations).

The code uses only the base MATLAB functions and hence should be compatible with GNU Octave, for those without a MATLAB license.

Please do note the licensing terms, when redistributing the code.
