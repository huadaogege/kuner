//
//  kac_http.h
//  taig.http
//
//  Created by Aeolos on 14-10-25.
//  Copyright (c) 2014年 Aeolos. All rights reserved.
//

#ifndef __taig_http__kac_http__
#define __taig_http__kac_http__

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

	/**** USAGE:
	 char taig_url[1024];
	 size_t taig_url_len = sizeof(taig_url);
	 int rt = taig_http_prepare_url(filename, taig_url, &taig_url_len);
	 if (rt) return -1;
	 ...
	 ****/
	extern int taig_http_prepare_url(const char* filename, char* taig_url, size_t* slen);
	
	/**** USAGE:
	 char* url = "http://127.0.0.1:62344/Test 123/abc.mp3";
	 char* eurl = 0;
	 int rt = taig_malloc_encode_url(url, &eurl);
	 if (rt == 0 && eurl) {
	   todo ...
	   free(eurl);
	 }
	 else {
	   error occured!
	   ....
	 }
	 ****/
	extern int taig_malloc_encode_url(const char* str, char** encoded_url);

	extern int taig_http_clear(void);
	extern int taig_http_disconnect_all(void);

#ifdef __cplusplus
}
#endif

#endif /* defined(__taig_http__kac_http__) */
