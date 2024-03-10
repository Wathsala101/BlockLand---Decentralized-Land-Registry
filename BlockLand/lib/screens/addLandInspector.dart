import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:land_registration/providers/LandRegisterModel.dart';
import 'package:land_registration/widget/menu_item_tile.dart';
import 'package:provider/provider.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

import '../constant/utils.dart';
import '../providers/MetamaskProvider.dart';

class AddLandInspector extends StatefulWidget {
  const AddLandInspector({Key? key}) : super(key: key);

  @override
  _AddLandInspectorState createState() => _AddLandInspectorState();
}

class _AddLandInspectorState extends State<AddLandInspector> {
  late String address, name, age, desig, city, newaddress;
  var model, model2;
  double width = 490;
  int screen = 0;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Menu> menuItems = [
    Menu(
        title: 'Add Land Inspector',
        icon: Icons.group_add_rounded,
        color: Colors.black),
    Menu(title: 'View Land Inspectors', icon: Icons.group, color: Colors.white),
    Menu(
        title: 'Change Credentials',
        icon: Icons.change_circle,
        color: Colors.white),
    Menu(title: 'Logout', icon: Icons.logout),
  ];

  List<List<dynamic>> allLandInspectorInfo = [];

  @override
  Widget build(BuildContext context) {
    model = Provider.of<LandRegisterModel>(context);
    model2 = Provider.of<MetaMaskProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF6F3284),
        leading: isDesktop
            ? Container()
            : GestureDetector(
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.menu,
                    color: Colors.white,
                  ), //AnimatedIcon(icon: AnimatedIcons.menu_arrow,progress: _animationController,),
                ),
                onTap: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
              ),
        title: const Text(
          'Admin Portal',
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: drawer2(),
      drawerScrimColor: Colors.transparent,
      body: Row(
        children: [
          isDesktop ? drawer2() : Container(),
          if (screen == 0)
            addLandInspector()
          else if (screen == 1)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(25),
                child: landInspectorList(),
              ),
            )
          else if (screen == 2)
            changeContractOwner()
        ],
      ),
    );
  }

  getLandInspectorInfo() async {
    setState(() {
      isLoading = true;
    });
    List<dynamic> landList;
    if (connectedWithMetamask)
      landList = await model2.allLandInspectorList();
    else
      landList = await model.allLandInspectorList();

    List<List<dynamic>> info = [];
    List<dynamic> temp;
    for (int i = 0; i < landList.length; i++) {
      if (connectedWithMetamask)
        temp = await model2.landInspectorInfo(landList[i]);
      else
        temp = await model.landInspectorInfo(landList[i]);
      info.add(temp);
    }
    allLandInspectorInfo = info;
    setState(() {
      isLoading = false;
    });
    print(info);
  }

  Widget landInspectorList() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount:
          allLandInspectorInfo == null ? 1 : allLandInspectorInfo.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Column(
            children: [
              const Divider(
                height: 15,
              ),
              Row(
                children: const [
                  Expanded(
                    child: Text(
                      'No',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                      child: Center(
                        child: Text('Address',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      flex: 5),
                  Expanded(
                    child: Center(
                      child: Text('Name',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    flex: 3,
                  ),
                  Expanded(
                    child: Center(
                      child: Text('City',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    flex: 2,
                  ),
                  Expanded(
                    child: Center(
                      child: Text('Delete',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    flex: 2,
                  )
                ],
              ),
              const Divider(
                height: 15,
              )
            ],
          );
        }
        index -= 1;
        List<dynamic> data = allLandInspectorInfo[index];
        return ListTile(
          title: Row(
            children: [
              Expanded(
                child: Text((index + 1).toString()),
                flex: 1,
              ),
              Expanded(
                  child: Center(
                    child: Text(data[1].toString()),
                  ),
                  flex: 5),
              Expanded(
                  child: Center(
                    child: Text(data[2].toString()),
                  ),
                  flex: 3),
              Expanded(
                  child: Center(
                    child: Text(data[5].toString()),
                  ),
                  flex: 2),
              Expanded(
                  child: Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.red),
                        onPressed: () async {
                          confirmDialog(
                              'Are you sure you want to permanently delete?',
                              context, () async {
                            SmartDialog.showLoading();
                            if (connectedWithMetamask)
                              await model2.removeLandInspector(data[1]);
                            else
                              await model.removeLandInspector(data[1]);
                            Navigator.pop(context);
                            await getLandInspectorInfo();
                            SmartDialog.dismiss();
                          });
                        },
                        child: const Text('Remove')),
                  ),
                  flex: 2),
            ],
          ),
        );
      },
    );
  }

  Widget changeContractOwner() {
    return Center(
      widthFactor: isDesktop ? 2 : 1,
      child: Container(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              const Text(
                "Change Contract Owner",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    newaddress = val;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Address',
                    hintText: 'Enter new Contract Owner Address',
                  ),
                ),
              ),
              CustomButton(
                  'Change',
                  isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            if (connectedWithMetamask)
                              await model2.changeContractOwner(newaddress);
                            else
                              await model.changeContractOwner(newaddress);
                            showToast("Successfully Changed",
                                context: context,
                                backgroundColor: Colors.green);
                          } catch (e) {
                            print(e);
                            showToast("Something Went Wrong",
                                context: context, backgroundColor: Colors.red);
                          }
                          setState(() {
                            isLoading = false;
                          });
                        }),
              isLoading ? const CircularProgressIndicator() : Container()
            ],
          ),
        ),
      ),
    );
  }

  Widget addLandInspector() {
    return Center(
      widthFactor: isDesktop ? 2 : 1,
      child: Container(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the details';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      address = val;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Address (Confidential)',
                      hintText: 'Enter Land Inspector Address',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the address to continue';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      name = val;
                    },
                    //obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Full Name the Land Registrar',
                      hintText: 'Enter the full name',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter full name';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      age = val;
                    },
                    //obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Registrar ID',
                      hintText: 'Enter the ID',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the ID';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      desig = val;
                    },
                    //obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Designation - Incharge Area',
                      hintText: 'Enter Designation and incharge area',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the designation';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      city = val;
                    },
                    //obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Incharge Area',
                      hintText: 'Enter the area of incharge',
                    ),
                  ),
                ),
                CustomButton(
                    'Add Land Registrar',
                    isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              try {
                                if (connectedWithMetamask)
                                  await model2.addLandInspector(
                                      address, name, age, desig, city);
                                else
                                  await model.addLandInspector(
                                      address, name, age, desig, city);
                                showToast("Successfully Added",
                                    context: context,
                                    backgroundColor: Colors.green);
                              } catch (e) {
                                print(e);
                                showToast("Something Went Wrong",
                                    context: context,
                                    backgroundColor: Colors.red);
                              }
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }),
                isLoading ? const CircularProgressIndicator() : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget drawer2() {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black26, spreadRadius: 2)
        ],
        color: Color(0xFF6F3284),
      ),
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            width: 100,
          ),
          const Icon(
            Icons.pin_drop_outlined,
            size: 60,
          ),
          const SizedBox(
            width: 60,
          ),
          const Text('Admin - Ministry of Lands',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(
            height: 80,
          ),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, counter) {
                return const Divider(
                  height: 2,
                );
              },
              itemCount: menuItems.length,
              itemBuilder: (BuildContext context, int index) {
                return MenuItemTile(
                  title: menuItems[index].title,
                  icon: menuItems[index].icon,
                  isSelected: screen == index,
                  onTap: () {
                    if (index == 3) {
                      Navigator.pop(context);
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) => home_page()));
                      Navigator.of(context).pushNamed(
                        '/',
                      );
                    }
                    if (index == 1) getLandInspectorInfo();

                    setState(() {
                      screen = index;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
