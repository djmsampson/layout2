function [a, d] = fontmetrics( ~, s, u, t )
%fontmetrics  Font metrics
%
%  [a,d] = uix.fontmetrics(n,s,u,t) returns metrics for the font with name
%  n, size s and units u in the figure type t ('java' or 'js').  The
%  metrics are the distances from the top to the ascent a and the descent d
%  in pixels.
%
%  Currently, metrics are based on MS Sans Serif on Windows on a 3840x2400
%  display with 225% scaling, and do not vary by font.  In future, metrics
%  for more fonts will be added.

%  Copyright 2024-2025 The MathWorks, Inc.

switch u
    case 'pixels'
        s = s / get( groot(), 'ScreenPixelsPerInch' ) * 72;
    case 'inches'
        s = s * 72;
    case 'points'
        % ok
    case 'centimeters'
        s = s * 72 / 2.54;
    otherwise
        error( 'uix:InvalidArgument', 'Unsupported font units ''%s''.', u )
end

switch t
    case 'java'
        aa = [ ...
              0     0     1     3     4     5     6     7     7     8 ...
              9    10    11    12    13    12    13    14    15    16 ...
             17    17    18    19    20    21    22    23    23    24 ...
             25    26    27    27    28    29    30    31    31    32 ...
             33    34    35    35    36    37    38    39    40    40 ...
             41    42    43    44    44    45    46    47    48    49 ...
             49    50    51    52    53    54    55    56    57    58 ...
             59    59    60    61    62    63    63    64    65    66 ...
             67    67    68    69    70    71    72    72    73    74 ...
             75    76    76    77    78    79    80    81    81    82 ...
             83    84    85    85    86    87    88    89    90    90 ...
             91    92    93    94    94    95    96    97    98    98 ...
             99   100   101   102   103   103   104   106   107   108 ...
            108   109   110   111   112   113   113   114   115   116 ...
            117   117   118   119   120   121   122   122   123   124 ...
            125   126   126   127   128   129   130   130   131   132 ...
            133   134   135   135   136   137   138   139   139   140 ...
            141   142   143   144   144   145   146   147   148   148 ...
            149   150   151   152   153   153   154   155   156   158 ...
            158   159   160   161   162   162   163   164   165   166 ...
            ]/2.25;
        dd = [ ...
              3     6    10    14    18    22    25    29    32    36 ...
             40    43    47    50    54    58    61    65    68    72 ...
             76    80    84    87    91    95    98   102   105   109 ...
            112   116   120   124   128   131   135   138   142   146 ...
            149   153   157   160   164   167   171   175   178   182 ...
            186   189   193   197   200   204   207   211   215   218 ...
            222   226   229   233   236   241   245   248   252   256 ...
            259   263   267   270   274   277   281   285   288   292 ...
            296   299   303   306   310   314   317   321   325   328 ...
            332   336   339   343   346   350   354   357   361   365 ...
            368   372   375   379   383   386   390   394   397   401 ...
            405   408   412   415   419   423   426   430   434   437 ...
            441   444   448   452   455   459   463   467   471   475 ...
            478   482   485   489   493   496   500   504   507   511 ...
            514   518   522   525   529   533   536   540   544   547 ...
            551   554   558   562   565   569   573   576   580   583 ...
            587   591   594   598   602   605   609   613   616   620 ...
            623   627   631   634   638   642   645   649   652   656 ...
            660   663   667   671   674   678   682   685   689   693 ...
            697   701   704   708   712   715   719   722   726   730 ...
            ]/2.25;
    case 'js'
        aa = [ ...
              1     4     2     4     5     7     8     9    11    11 ...
             10    12    15    14    15    16    17    18    19    19 ...
             22    24    25    23    25    28    27    29    30    32 ...
             32    33    33    36    37    37    38    39    40    41 ...
             42    43    44    46    46    46    47    50    50    51 ...
             51    53    54    56    56    57    59    58    59    60 ...
             63    63    64    65    66    67    68    70    71    73 ...
             71    72    74    75    76    77    78    80    79    82 ...
             84    82    85    85    86    88    88    89    91    92 ...
             94    93    93    97    96    99    99    99   101   102 ...
            101   105   106   106   106   107   111   110   110   112 ...
            113   114   116   117   118   119   120   120   121   121 ...
            123   124   126   127   128   129   130   129   133   134 ...
            133   134   135   137   138   139   140   141   141   144 ...
            143   146   145   146   148   149   151   151   152   154 ...
            155   154   157   156   158   159   160   162   162   161 ...
            165   166   166   168   167   169   170   171   173   173 ...
            175   176   175   177   179   179   182   181   183   183 ...
            184   186   187   189   190   188   190   193   192   194 ...
            194   196   197   198   200   201   201   203   202   204 ...
            ]/2.25;
        dd = [ ...
              4     9    11    15    19    24    28    32    35    40 ...
             41    45    51    54    58    62    66    70    73    76 ...
             82    86    90    91    96   102   103   108   111   116 ...
            120   123   126   131   135   138   141   146   149   153 ...
            158   162   166   170   174   176   180   186   188   192 ...
            195   200   204   208   212   216   220   222   226   230 ...
            236   239   242   246   250   254   258   262   266   271 ...
            272   276   280   284   288   292   296   301   302   308 ...
            312   314   320   322   326   331   334   338   342   346 ...
            351   352   356   363   364   370   372   376   381   384 ...
            386   393   396   400   402   406   413   415   418   423 ...
            427   430   435   438   443   447   450   452   456   460 ...
            464   468   472   476   480   484   488   490   496   500 ...
            503   506   510   514   518   522   526   530   533   538 ...
            540   546   548   552   556   560   565   568   572   576 ...
            580   582   588   590   595   598   602   606   610   612 ...
            618   622   625   630   632   636   640   644   648   652 ...
            657   660   662   666   672   675   680   682   687   690 ...
            694   698   702   707   710   712   717   722   724   728 ...
            732   737   740   744   749   752   756   761   762   767 ...
            ]/2.25;
    otherwise
        error( 'uix:InvalidArgument', 'Unsupported figure type ''%s''.', t )
end

% Bound and round font size
s = max( s, 1 );
s = min( s, 200 );
s = round( s );

% Select
a = aa(s);
d = dd(s);

end % fontmetrics