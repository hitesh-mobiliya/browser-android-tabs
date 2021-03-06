// Copyright 2014 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "ios/web/webui/shared_resources_data_source_ios.h"

#include <stddef.h>

#include "base/logging.h"
#include "base/memory/ref_counted_memory.h"
#include "base/strings/string_util.h"
#import "ios/web/public/web_client.h"
#include "net/base/mime_util.h"
#include "ui/base/webui/web_ui_util.h"
#include "ui/resources/grit/webui_resources.h"
#include "ui/resources/grit/webui_resources_map.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

namespace web {

namespace {

// Value duplicated from content/public/common/url_constants.h
// TODO(stuartmorgan): Revisit how to share this in a more maintainable way.
const char kWebUIResourcesHost[] = "resources";

// Maps a path name (i.e. "/js/path.js") to a resource map entry. Returns
// nullptr if not found.
const GzippedGritResourceMap* PathToResource(const std::string& path) {
  for (size_t i = 0; i < kWebuiResourcesSize; ++i) {
    if (path == kWebuiResources[i].name)
      return &kWebuiResources[i];
  }
  return nullptr;
}

}  // namespace

SharedResourcesDataSourceIOS::SharedResourcesDataSourceIOS() {}

SharedResourcesDataSourceIOS::~SharedResourcesDataSourceIOS() {}

std::string SharedResourcesDataSourceIOS::GetSource() const {
  return kWebUIResourcesHost;
}

void SharedResourcesDataSourceIOS::StartDataRequest(
    const std::string& path,
    const URLDataSourceIOS::GotDataCallback& callback) {
  const GzippedGritResourceMap* resource = PathToResource(path);
  DCHECK(resource) << " path: " << path;
  scoped_refptr<base::RefCountedMemory> bytes;

  WebClient* web_client = GetWebClient();

  int idr = resource ? resource->value : -1;
  if (idr == IDR_WEBUI_CSS_TEXT_DEFAULTS) {
    std::string css = webui::GetWebUiCssTextDefaults();
    bytes = base::RefCountedString::TakeString(&css);
  } else {
    bytes = web_client->GetDataResourceBytes(idr);
  }

  callback.Run(bytes.get());
}

std::string SharedResourcesDataSourceIOS::GetMimeType(
    const std::string& path) const {
  std::string mime_type;
  net::GetMimeTypeFromFile(base::FilePath().AppendASCII(path), &mime_type);
  return mime_type;
}

bool SharedResourcesDataSourceIOS::IsGzipped(const std::string& path) const {
  const GzippedGritResourceMap* resource = PathToResource(path);
  return resource && resource->gzipped;
}

}  // namespace web
