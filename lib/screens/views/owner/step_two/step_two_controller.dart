import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:built_collection/src/list.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/graphql/propertycreation/__generated__/propertycreation.data.gql.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/utils/common_file_picker.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_list_item.dart';
import 'package:gozy/widgets/owner/step_item_model.dart';

import '../../../../app.dart';
import '../../../../config/client.dart';
import '../../../../graphql/__generated__/listing_fragment.data.gql.dart';
import '../../../../graphql/__generated__/listing_fragment.req.gql.dart';
import '../../../../graphql/propertycreation/__generated__/propertycreation.req.gql.dart';
import '../../../../utils/text_editing_controller.dart';

class StepTwoController extends BaseController {
  List<String> removeablePhotos = [];
  dynamic itemInfo;
  List<String> removingPhotoList = [];
  List<Map<String, dynamic>> steptwo_layout_items = [];
  RxList<String> uploadingPhotos = RxList<String>();
  RxInt choosedIndex = 0.obs;
  int? coverphotoid;
  RxString selectedImageOption = ''.obs;
  RxBool isFilesPicking = false.obs;
  RxInt selectedChipIndex = 0.obs;
  bool isInUploadpage = false;
  RxString skipbtnText = btn_label_skip_for_now.tr.obs;
  Map<String, Widget> uploadingplaceholder = {};
  int photocount = 0;
  CustomTextEditingController propertyTitleController =
      CustomTextEditingController();
  CustomTextEditingController propertyDescController =
      CustomTextEditingController();
  Future? photoUploadingFuture;
  Completer<bool> photoUploadCompleter = Completer<bool>();
  ScrollController scrollController = ScrollController();
  RxSet<StepItemModel> selectedTitleContents = <StepItemModel>{}.obs;

  @override
  onReady() {
    StepItemModel itemModel = StepItemModel(
      itemName: '',
      itemValue: appPreference.preferredLanguage,
    );
    selectedTitleContents.add(itemModel);
    availableCameras().then((value) {
      cameras = value;
    });
    super.onReady();
  }

  (GviewListingDetailsFragmentData?, GviewListingDetailsFragmentReq)
      getItemInfo() {
    GviewListingDetailsFragmentReq fragmentReq = GviewListingDetailsFragmentReq(
        (b) => b..idFields = {'id': itemInfo.id});
    var data = FerryLoggerClient.client?.cache.readFragment(fragmentReq);
    if (data == null && itemInfo != null) {
      try {
        data = GviewListingDetailsFragmentData.fromJson(itemInfo.toJson());
        if (data != null) {
          FerryLoggerClient.client?.cache.writeFragment(fragmentReq, data);
        }
      } catch (e) {
        debugPrint('Error parsing itemInfo to Fragment: $e');
      }
    }
    return (data, fragmentReq);
  }

  final languageEntries = <LanguageEntry>[].obs;

  void initFromApi() {
    final titles = _cleanDynamicJson(itemInfo.dynamicListingTitle);
    final descs = _cleanDynamicJson(itemInfo.dynamicListingDescription);
    String primacyLang = "";
    languageEntries.clear();
    print("AllLanguages--> $allLanguages");
    if (titles.isNotEmpty) {
      titles.forEach((lang, title) {
        if (primacyLang.trim().isEmpty) {
          primacyLang = lang;
        }
        final desc = descs[lang] ?? '';
        if (title.trim().isNotEmpty || desc.trim().isNotEmpty) {
          languageEntries.add(LanguageEntry(
              langCode: (allLanguages[lang]?.isNotEmpty ?? false) ? lang : '',
              titleController: CustomTextEditingController(text: title),
              descController: CustomTextEditingController(text: desc),
              isWritten: false.obs));
        }
      });
    }

    if (languageEntries.isEmpty) {
      languageEntries.add(LanguageEntry(
          langCode: "",
          titleController: CustomTextEditingController(text: ""),
          descController: CustomTextEditingController(text: ""),
          isWritten: false.obs));
    }
  }

  Map<String, String> _cleanDynamicJson(dynamic list) {
    if (list == null) return {};
    final cleaned = <String, String>{};
    if (list is Iterable) {
      for (var item in list) {
        if (item == null) continue;
        try {
          final lang = item.language?.toString() ?? '';
          String text = '';
          try { text = item.listTitle?.toString() ?? ''; } catch (_) {}
          try { if (text.isEmpty) text = item.listDescription?.toString() ?? ''; } catch (_) {}
          
          if (lang.isNotEmpty) {
            cleaned[lang] = text;
          }
        } catch (e) {
          if (item is Map) {
            final lang = item['language']?.toString() ?? '';
            final text = (item['listTitle'] ?? item['listDescription'])?.toString() ?? '';
            if (lang.isNotEmpty) {
              cleaned[lang] = text;
            }
          }
        }
      }
    } else if (list is Map) {
      list.forEach((key, value) {
        if (key != '__typename' && key != 'G__typename') {
          cleaned[key.toString()] = value?.toString() ?? '';
        }
      });
    }
    return cleaned;
  }

  void addLanguageEntry() {
    languageEntries.add(LanguageEntry(
        langCode: null,
        titleController: CustomTextEditingController(),
        descController: CustomTextEditingController(),
        isWritten: false.obs));
  }

  void removeLanguageEntry(int index) {
    if (languageEntries.length > 1) {
      languageEntries.removeAt(index);
    }
  }

  List<MapEntry<String, String>> getAvailableLanguages(int currentIndex) {
    final selectedLangs = languageEntries
        .asMap()
        .entries
        .where((e) => e.key != currentIndex && e.value.langCode != null)
        .map((e) => e.value.langCode)
        .toSet();

    final currentLang = languageEntries[currentIndex].langCode;

    return allLanguages.entries
        .where((e) => !selectedLangs.contains(e.key) || e.key == currentLang)
        .toList();
  }

  Map<String, String> getTitleMapForApi() {
    final map = <String, String>{};
    for (var e in languageEntries) {
      if (e.langCode != null) {
        map[e.langCode!] = e.titleController.text.trim();
      }
    }
    return map;
  }

  Map<String, String> getDescMapForApi() {
    final map = <String, String>{};
    for (var e in languageEntries) {
      if (e.langCode != null) {
        map[e.langCode!] = e.descController.text.trim();
      }
    }
    return map;
  }

  void updatePhotosOnFragment(
      {required dynamic fileName, required String functionName}) {
    (GviewListingDetailsFragmentData?, GviewListingDetailsFragmentReq) info =
        getItemInfo();
    ListBuilder<GviewListingDetailsFragmentData_listPhotos?>?
        listphotosBuilder = info.$1?.listPhotos?.toBuilder();
    String coverPhoto = '';
    String? title, desc;
    List<Map<String, String>>? dynamicTitelDesc;
    switch (functionName) {
      case 'add':
        final listbuilder = GviewListingDetailsFragmentData_listPhotosBuilder()
          ..name = fileName['filename']
          ..id = fileName['id'];

        listphotosBuilder?.add(listbuilder.build());
        skipbtnText.value = btn_label_next.tr;

      case 'remove':
        // Ensure fileName is handled correctly (original logic used it as a String here)
        listphotosBuilder?.removeWhere((item) => item?.name == fileName);

        if (removingPhotoList.isNotEmpty) {
          removingPhotoList.removeLast();
        }

        if (listphotosBuilder == null || listphotosBuilder.isEmpty) {
          skipbtnText.value = btn_label_skip_for_now.tr;
        }

      case 'update':
        final entry = languageEntries.firstOrNull;
        title = entry?.titleController.text.trim() ?? '';
        desc = entry?.descController.text.trim() ?? '';

        dynamicTitelDesc = buildDynamicListTitleAndDesc();
    }

    var listphotolist = listphotosBuilder?.build().toList();
    listphotolist?.forEach((element) {
      int? id = element?.id;
      if (id != null && id == (coverphotoid ?? itemInfo.coverPhoto)) {
        coverPhoto = element?.name ?? '';
      }
    });

    if (coverPhoto.isEmpty &&
        listphotolist != null &&
        listphotolist.isNotEmpty) {
      coverPhoto = listphotolist[0]?.name ?? '';
      coverphotoid = listphotolist[0]?.id;
    } else if (listphotolist == null || listphotolist.isEmpty) {
      coverphotoid = null;
    }
    if (info.$1 != null) {
      FerryLoggerClient.client?.cache.writeFragment(
          info.$2,
          info.$1!.rebuild((builder) {
            builder
              ..coverPhoto = coverphotoid != null &&
                      listphotolist != null &&
                      listphotolist.isNotEmpty &&
                      functionName == 'update'
                  ? coverphotoid
                  : listphotolist == null || listphotolist.isEmpty
                      ? null
                      : itemInfo.coverPhoto
              ..listPhotoName = coverPhoto.isNotEmpty &&
                      functionName == 'update'
                  ? coverPhoto
                  : listphotosBuilder != null && listphotosBuilder.isNotEmpty
                      ? listphotosBuilder[0]!.name
                      : null;
            builder
              ..title = title ?? itemInfo.title
              ..description = desc ?? itemInfo.description
              ..listPhotos = listphotosBuilder;
          }));
    }

    isLoading.refresh();
    Get.forceAppUpdate();
  }

  updateInitialCoverPhotoOnFragment(int? coverPhotoId, String? coverPhoto) {
    (GviewListingDetailsFragmentData?, GviewListingDetailsFragmentReq) info =
        getItemInfo();
    if (info.$1 != null) {
      FerryLoggerClient.client?.cache.writeFragment(
          info.$2,
          info.$1!.rebuild((builder) {
            builder
              ..coverPhoto = coverPhotoId
              ..listPhotoName = coverPhoto;
          }));
    }
  }

  void updateTitleDescOnFragment() {
    (GviewListingDetailsFragmentData?, GviewListingDetailsFragmentReq) info =
        getItemInfo();

    final dynamicTitleBuilder = ListBuilder<GviewListingDetailsFragmentData_dynamicListingTitle?>();
    final dynamicDescBuilder = ListBuilder<GviewListingDetailsFragmentData_dynamicListingDescription?>();

    final mainEntry = languageEntries.firstOrNull;
    final mainTitle = mainEntry?.titleController.text.trim() ?? '';
    final mainDesc = mainEntry?.descController.text.trim() ?? '';

    for (final entry in languageEntries) {
      final lang = entry.langCode ?? '';
      final title = entry.titleController.text.trim();
      final desc = entry.descController.text.trim();
      dynamicTitleBuilder.add(
          GviewListingDetailsFragmentData_dynamicListingTitle.fromJson({
            "language": lang,
            "listTitle": title
          })!
      );

      dynamicDescBuilder.add(
          GviewListingDetailsFragmentData_dynamicListingDescription.fromJson({
            "language": lang,
            "listDescription": desc
          })!
      );
    }

    if (info.$1 != null) {
      FerryLoggerClient.client?.cache.writeFragment(
          info.$2,
          info.$1!.rebuild((builder) {
            builder
              ..title = mainTitle.isNotEmpty ? mainTitle : itemInfo.title
              ..description =
                  mainDesc.isNotEmpty ? mainDesc : itemInfo.description
              ..dynamicListingTitle = dynamicTitleBuilder
              ..dynamicListingDescription = dynamicDescBuilder;
          }));
    }

    isLoading.refresh();
    Get.forceAppUpdate();
  }

  removeListPhotos() {
    isShowLoader = false;
    final params = GRemoveListPhotosReq((b) => b
      ..vars.listId = itemInfo.id
      ..vars.name = removingPhotoList.last
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, removeListPhotos, isViewLoader: false, isStartLoader: false, isToGet400Message: true)?.then((res) {
      if(res.data.removeListPhotos.status == 200) {
        updatePhotosOnFragment(fileName: removingPhotoList.last, functionName: 'remove');
      }
      removingPhotoList.clear();
      isLoading.value = false;
    });
  }

  void validateStep2Info() {
    final Map<String, bool> _results = {};

    try {
      if (languageEntries.isEmpty) {
        _results[error_msg_empty.trParams({
          'field': label_title_to_your_list.tr.toLowerCase(),
        })] = true;
      } else {
        for (final entry in languageEntries) {
          final String langCode = entry.langCode ?? "";
          final bool langEmpty = langCode.trim().isEmpty;
          final bool titleEmpty = entry.titleController.text.trim().isEmpty;
          final bool descEmpty = entry.descController.text.trim().isEmpty;

          _results["label_please_select_language".tr] = langEmpty;
          _results[error_msg_empty.trParams({'field': label_title_to_your_list.tr.toLowerCase()})] = titleEmpty;
          _results[error_msg_empty.trParams({'field': label_description_to_your_list.tr.toLowerCase()})] = descEmpty;
          if(langEmpty || titleEmpty || descEmpty) break;
        }
      }

      print("_results--> $_results");
      final bool validate = _results.isValidate(controller: this);

      if (validate) {
        updateTitleDescOnFragment();
        checkNetwork(updateStep2Details);
      }
    } catch (e, st) {
      debugPrint("validateStep2Info crashed: $e");
      debugPrint("$st");
    }
  }

  updateStep2Details() {
    customMultipartRequest?.close();
    uploadingPhotos.clear();
    isShowLoader = true;
    final dynamicListTitleAndDesc = buildDynamicListTitleAndDesc();
    final String mainTitle = languageEntries.isNotEmpty
        ? languageEntries.first.titleController.text.trim()
        : '';
    final String mainDesc = languageEntries.isNotEmpty
        ? languageEntries.first.descController.text.trim()
        : '';
    final params = GUpdateListingStep2Req(
      (b) => b
        ..vars.id = itemInfo.id
        ..vars.coverPhoto = coverphotoid ?? itemInfo.coverPhoto
        ..vars.title = mainTitle
        ..vars.description = mainDesc
        ..vars.dynamicListTitleandDesc = jsonEncode(dynamicListTitleAndDesc)
        ..vars.build(),
    );
    FerryLoggerClient.makeRequest(params, this, updateStep2Details,
            isViewLoader: true,
            isToGet400Message: true,
            isViewErrorMessage: false,
            isAutoCloseLoader: false)
        ?.then((res) {
      GUpdateListingStep2Data step2data = res.data as GUpdateListingStep2Data;
      if (step2data?.updateListingStep2?.status == 200) {
        checkNetwork(manageListingSteps);
      } else {
        showSnackBar(label_empty_listing.tr, isltralign: true);
        Get.back(result: {'removedeletedlisting': true});
      }
    });
  }

  List<Map<String, String>> buildDynamicListTitleAndDesc() {
    final List<Map<String, String>> result = [];

    for (final entry in languageEntries) {
      final lang = entry.langCode ?? '';
      final title = entry.titleController.text.trim();
      final desc = entry.descController.text.trim();

      if (lang.isNotEmpty && (title.isNotEmpty || desc.isNotEmpty)) {
        result.add({
          'listTitle': title,
          'listDescription': desc,
          'language': lang,
        });
      }
    }
    return result;
  }

  void manageListingSteps() {
    final params = GmanageListingStepsReq((b) => b
      ..vars.listId = itemInfo.id.toString()
      ..vars.currentStep = 2
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, manageListingSteps,
            isViewLoader: true, isAutoCloseLoader: false)
        ?.then((res) {
      isLoading.value = false;
      (
        GviewListingDetailsFragmentData?,
        GviewListingDetailsFragmentReq
      ) datareq = getItemInfo();
      final data = datareq.$1;
      GviewListingDetailsFragmentData_listingStepsBuilder listingstepsBuilder =
          data?.listingSteps != null
              ? data!.listingSteps!.toBuilder()
              : GviewListingDetailsFragmentData_listingStepsBuilder();
      listingstepsBuilder.step1 = res.data.manageListingSteps?.results?.step1;
      listingstepsBuilder.step2 = res.data.manageListingSteps?.results?.step2;
      listingstepsBuilder.step3 = res.data.manageListingSteps?.results?.step3;
      if (data != null) {
        FerryLoggerClient.client?.cache.writeFragment(
            datareq.$2,
            data.rebuild((b) => b
              ..isPublished = data.isPublished ?? false
              ..lastUpdatedAt = DateTime.now().millisecondsSinceEpoch.toString()
              ..listingSteps = listingstepsBuilder));
      }

      updatePhotosOnFragment(fileName: '', functionName: 'update');
      isLoading.value = false;
      Get.back();
    });
  }

  void pickFile([bool? isFromCamera]) async {
    onBack();
    if (!isFilesPicking.value) {
      callBackFunction();
    }
  }

  void callBackFunction() async {
    bool isNetconnected = await isNetworkConnected();
    isShowLoader = false;
    if (isNetconnected) {
      CommonFilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        compressionQuality: compressImageQuality,
        onFileLoading: (status) {
          isFilesPicking.value = (status == FilePickerStatus.picking);
        },
      ).then((result) async {
        isFilesPicking.value = false;
        bool isnetConnected = await isNetworkConnected();
        if (isnetConnected) {
          List<PlatformFile> files = [];
          if (result != null) {
            Get.closeCurrentSnackbar();
            for (var pickfile in result.files) {
              files.add(pickfile);
            }
            files.sort((a, b) {
              return b.size.compareTo(a.size);
            });
            List<Future<XFile?>> compressingFuture = [];
            for (var pickfile in files) {
              if (isInUploadpage) {
                compressingFuture.add(compressImage(pickfile.path!));
              }
            }
            Future.wait(compressingFuture).then((xfilesList) {
              for (var xfile in xfilesList) {
                if (isInUploadpage) {
                  uploadingPhotos.add(xfile!.path);
                  if (xfilesList.last == xfile && isInUploadpage) {
                    if (photoUploadingFuture != null) {
                      Future.wait([photoUploadingFuture!]).then((value) {
                        photoUploadingFuture = UploadSelectedFiles();
                      });
                    } else {
                      photoUploadingFuture = UploadSelectedFiles();
                    }
                  }
                }
              }
            });
          }
        }
      });
    }
  }

  Future<XFile?> compressImage(String filePath) async {
    var filepathlist = filePath.split('.');
    String extension = 'png';
    if (filepathlist.last == 'png' ||
        filepathlist.last == 'jpeg' ||
        filepathlist.last == 'jpg') {
      extension = filepathlist.last;
    }
    var dir = Directory.systemTemp;
    var targetPath = dir.absolute.path +
        "/temp_${DateTime.now().millisecondsSinceEpoch}_${photocount}.${extension}";
    photocount++;
    final compressedImage = await FlutterImageCompress.compressAndGetFile(
        filePath, targetPath,
        minWidth: 700,
        minHeight: 700,
        quality: compressImageQuality,
        format: extension == 'png' ? CompressFormat.png : CompressFormat.jpeg);

    return compressedImage;
  }

  Future<void> UploadSelectedFiles() async {
    List<String> filepaths = List.from(uploadingPhotos.value);
    removeablePhotos.forEach((element) {
      filepaths.remove(element);
    });
    if (filepaths.isNotEmpty) {
      File compressedfile;
      for (int i = 0; i < filepaths.length; i++) {
        String pickfile = filepaths[i];
        if (!isInUploadpage || removeablePhotos.contains(removeablePhotos)) {
          return;
        }

        // if(scrollController.hasClients) scrollController.movetoposition(toBottom: true);
        compressedfile = File(pickfile);
        bool isnetConnected = await isNetworkConnected(isshowToast: false);
        if (isnetConnected) {
          if (removeablePhotos.isNotEmpty) {
            photoUploadCompleter = Completer();
          }

          Get.closeCurrentSnackbar();

          removeablePhotos = addItem(removeablePhotos, compressedfile.path);
          var uploadedfile = await uploadImage(
              file: compressedfile,
              uploadUrl: uploadListPhoto,
              listid: itemInfo.id,
              uploadingImages: uploadingPhotos);

          if (uploadedfile.isNotEmpty && uploadedfile != 'network') {
            Map<String, dynamic> uploadingmap =
                uploadedfile as Map<String, dynamic>;
            uploadingplaceholder[uploadingmap['filename'].toString()] =
                getuploadingWidget(pickfile);
            updatePhotosOnFragment(fileName: uploadingmap, functionName: 'add');
            removeablePhotos = addItem(removeablePhotos, compressedfile.path);
            for (var element in removeablePhotos) {
              uploadingPhotos.remove(element);
            }
            if (!photoUploadCompleter.isCompleted) {
              photoUploadCompleter.complete(true);
            }
          } else if (uploadedfile == 'network') {
            checkNetwork(UploadSelectedFiles);
          } else if (uploadedfile == '') {
            Get.back(result: {'removedeletedlisting': true});
          }
        } else {
          checkNetwork(UploadSelectedFiles);
        }
      }
    }
  }

  List<T> addItem<T>(List<T> list, T item) {
    List<T> listing = list.toSet().toList();
    listing.add(item);
    return listing;
  }
}

class LanguageEntry {
  String? langCode;
  final CustomTextEditingController titleController;
  final CustomTextEditingController descController;
  final RxBool? isWritten;

  LanguageEntry({
    required this.langCode,
    required this.titleController,
    required this.descController,
    this.isWritten,
  });
}

class DropdownItemModel {
  final int id;
  final String itemValue;
  final String itemName;
  DropdownItemModel({
    required this.id,
    required this.itemValue,
    required this.itemName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemValue': itemValue,
        'itemName': itemName,
      };
}