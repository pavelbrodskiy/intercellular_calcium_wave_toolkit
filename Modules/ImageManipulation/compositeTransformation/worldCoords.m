function [cPrime, nPrime, sPrime] = worldCoords(geometry)
outline = mask - imerrode(mask, strel('diamond',1));