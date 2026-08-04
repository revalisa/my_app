import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/pages/login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const Color primaryColor = Color(0xff932D4F);
  static const Color pinkColor = Color(0xffE0ADBE);


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xffFCF4F9),


      body: SafeArea(

        child: Stack(

          children: [


            // DECORATION

            Positioned(

              top: -80,

              right: -70,

              child: Container(

                width: 220,

                height: 220,

                decoration: BoxDecoration(

                  color:
                      pinkColor.withOpacity(0.35),

                  shape:
                      BoxShape.circle,

                ),

              ),

            ),



            Positioned(

              bottom: -100,

              left: -80,

              child: Container(

                width: 250,

                height: 250,

                decoration: BoxDecoration(

                  color:
                      pinkColor.withOpacity(0.25),

                  shape:
                      BoxShape.circle,

                ),

              ),

            ),



            Padding(

              padding:
                  const EdgeInsets.symmetric(
                    horizontal: 28,
                  ),


              child: Column(

                children: [


                  const Spacer(),



                  // LOGO

                  Container(

                    width: 170,

                    height: 170,


                    decoration: BoxDecoration(

                      gradient:
                          const LinearGradient(

                        colors: [

                          Color(0xffE8B7C8),

                          Color(0xffF5DCE5),

                        ],

                      ),


                      shape:
                          BoxShape.circle,


                      boxShadow: [

                        BoxShadow(

                          color:
                              primaryColor.withOpacity(.18),

                          blurRadius:
                              30,

                          offset:
                              const Offset(0,15),

                        )

                      ],

                    ),



                    child:
                        const Icon(

                      Icons.wallet_rounded,

                      size:
                          95,

                      color:
                          primaryColor,

                    ),

                  ),



                  const SizedBox(height:45),




                  // TITLE

                  Text(

                    "Finance\nTracker",

                    textAlign:
                        TextAlign.center,


                    style:
                        GoogleFonts.poppins(

                      fontSize:
                          38,

                      fontWeight:
                          FontWeight.bold,

                      color:
                          primaryColor,

                      height:
                          1.1,

                    ),

                  ),




                  const SizedBox(height:18),




                  Text(

                    "Take Control Of Your Money",

                    textAlign:
                        TextAlign.center,


                    style:
                        GoogleFonts.poppins(

                      fontSize:
                          20,

                      fontWeight:
                          FontWeight.w600,

                      color:
                          Colors.black87,

                    ),

                  ),




                  const SizedBox(height:14),




                  Text(

                    "Kelola keuangan lebih mudah.\n"
                    "Catat transaksi dan buat keputusan\n"
                    "finansial yang lebih baik.",


                    textAlign:
                        TextAlign.center,


                    style:
                        GoogleFonts.poppins(

                      fontSize:
                          14,

                      color:
                          Colors.grey.shade600,

                      height:
                          1.6,

                    ),

                  ),





                  const SizedBox(height:40),




                  // MINI CARD

                  Container(

                    width:
                        double.infinity,


                    padding:
                        const EdgeInsets.all(18),


                    decoration:
                        BoxDecoration(

                      color:
                          Colors.white,


                      borderRadius:
                          BorderRadius.circular(22),


                      boxShadow: [

                        BoxShadow(

                          color:
                              Colors.black.withOpacity(.06),

                          blurRadius:
                              20,

                          offset:
                              const Offset(0,8),

                        )

                      ],

                    ),



                    child:
                        Row(

                      children: [


                        Container(

                          width:
                              45,

                          height:
                              45,


                          decoration:
                              BoxDecoration(

                            color:
                                const Color(0xffFCECF2),

                            borderRadius:
                                BorderRadius.circular(14),

                          ),


                          child:
                              const Icon(

                            Icons.bar_chart_rounded,

                            color:
                                primaryColor,

                          ),

                        ),



                        const SizedBox(width:15),



                        Expanded(

                          child:
                              Text(

                            "Monitor your financial\n"
                            "growth easily",

                            style:
                                GoogleFonts.poppins(

                              fontSize:
                                  14,

                              fontWeight:
                                  FontWeight.w500,

                              color:
                                  Colors.black87,

                            ),

                          ),

                        )

                      ],

                    ),

                  ),




                  const Spacer(),





                  // BUTTON

                  SizedBox(

                    width:
                        double.infinity,


                    height:
                        58,


                    child:
                        ElevatedButton(

                      onPressed: () {


                        Navigator.pushReplacement(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                const LoginPage(),

                          ),

                        );


                      },


                      style:
                          ElevatedButton.styleFrom(

                        backgroundColor:
                            primaryColor,


                        foregroundColor:
                            Colors.white,


                        elevation:
                            8,


                        shape:
                            RoundedRectangleBorder(

                          borderRadius:
                              BorderRadius.circular(30),

                        ),

                      ),



                      child:
                          Row(

                        mainAxisAlignment:
                            MainAxisAlignment.center,


                        children: [


                          Text(

                            "Get Started",

                            style:
                                GoogleFonts.poppins(

                              fontSize:
                                  17,

                              fontWeight:
                                  FontWeight.w600,

                            ),

                          ),



                          const SizedBox(width:10),



                          const Icon(

                            Icons.arrow_forward_rounded,

                          )

                        ],

                      ),

                    ),

                  ),




                  const SizedBox(height:40),


                ],

              ),

            ),

          ],

        ),

      ),

    );

  }

}
