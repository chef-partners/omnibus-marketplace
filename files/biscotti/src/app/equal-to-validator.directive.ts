import { Directive } from '@angular/core';
import { forwardRef } from '@angular/core';
import { Attribute } from '@angular/core';
import { Validator } from '@angular/forms';
import { AbstractControl } from '@angular/forms';
import { NG_VALIDATORS } from '@angular/forms';

@Directive({
  selector: '[appEqualTo][formControlName],[appEqualTo][formControl],[appEqualTo][ngModel]',
  providers: [
    { provide: NG_VALIDATORS,
      useExisting: forwardRef(() => EqualToValidator),
      multi: true
    }
  ]
})
export class EqualToValidator implements Validator {
  constructor(
    @Attribute('appEqualTo') public appEqualTo: string,
    @Attribute('appForwardErrors') public appForwardErrors: string
  ) {}

  private get shouldForwardErrors() {
    if (!this.appForwardErrors) { return false; }
    return this.appForwardErrors === 'true' ? true : false;
  }

  validate(c: AbstractControl): { [key: string]: any } {
      const current_value = c.value;
      const desired_control = c.root.get(this.appEqualTo);

      if (desired_control && current_value !== desired_control.value && !this.shouldForwardErrors) {
        return {
          appEqualTo: false
        };
      }

      if (desired_control && current_value === desired_control.value && this.shouldForwardErrors) {
        delete desired_control.errors['appEqualTo'];
        if (!Object.keys(desired_control.errors).length) { desired_control.setErrors(null); }
      }

      if (desired_control && current_value !== desired_control.value && this.shouldForwardErrors) {
        desired_control.setErrors({ appEqualTo: false });
      }

      return null;
  }
}
