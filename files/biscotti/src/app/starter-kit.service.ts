import { Injectable } from '@angular/core';

import {
  HttpClient,
  HttpHeaders,
  HttpHeaderResponse,
  HttpErrorResponse,
  HttpEventType,
  HttpResponse,
} from '@angular/common/http';

import { Observable } from 'rxjs/Observable';

import { StarterKitForm } from './biscotti-setup/biscotti-starter-kit-form.type';

@Injectable()
export class StarterKitService {

  constructor(
    private http: HttpClient
  ) {
  }

  createStarterKit(form: StarterKitForm): Observable<Blob> {
    return this
      .http
      .post('/biscotti/setup/starter-kit', form, {
        headers: new HttpHeaders({
          'Content-Type': 'application/json',
          'Accept': 'application/zip'
        }),
        responseType: 'blob',
        observe: 'body'
      });
  }
}
